# terraform-podinfo

Terraform configuration that provisions an EKS cluster on AWS and deploys
[podinfo](https://github.com/stefanprodan/podinfo) behind an HTTPS-terminated
ALB with a Route 53-managed DNS record.

The stack is split in three layers, each with its own state:

- `bootstrap/` — Route 53 hosted zone. Long-lived; the nameserver delegation
  at the registrar is set up against this state once and survives
  rebuilds of everything downstream.
- `infra/` — VPC, EKS cluster, ACM certificate. Uses only the AWS provider.
  Reads `zone_id` from `bootstrap/` via `terraform_remote_state`.
- `apps/` — IRSA roles, AWS Load Balancer Controller, ExternalDNS, podinfo,
  Ingress. Uses the `kubernetes` and `helm` providers. Reads cluster
  endpoint/CA/OIDC from `infra/` and `zone_id` from `bootstrap/`.

Splitting `apps/` off `infra/` avoids the chicken-and-egg where the
`kubernetes` and `helm` providers depended on an EKS endpoint not yet known
at plan time. `apps/` now reads it as a plain string from infra's state.

## What gets created

**Bootstrap layer**

- Route 53 hosted zone for the chosen subdomain

**Infra layer**

- VPC across two AZs (public + private subnets, IGW, single NAT gateway)
- EKS cluster with a managed node group in the private subnets
- Core EKS add-ons: `vpc-cni`, `coredns`, `kube-proxy`
- IRSA OIDC provider
- ACM certificate (DNS-validated against the bootstrapped zone)

**Apps layer**

- IRSA roles for the ALB controller and ExternalDNS
- AWS Load Balancer Controller (Helm)
- ExternalDNS (Helm), reconciling Ingress hosts into Route 53
- podinfo Helm release and a Kubernetes Ingress that fronts it via the ALB

## Prerequisites

- Terraform `>= 1.5`
- An AWS account and a named CLI profile with admin-equivalent permissions
- A registered domain you control (delegation to Route 53 happens via the
  nameservers the bootstrap layer outputs)
- `kubectl` for poking at the cluster after apply

## Configure

Each layer has its own `terraform.tfvars.example`. Copy and fill in:

```sh
cp bootstrap/terraform.tfvars.example bootstrap/terraform.tfvars
cp infra/terraform.tfvars.example     infra/terraform.tfvars
cp apps/terraform.tfvars.example      apps/terraform.tfvars
```

Variables that appear in more than one layer (`profile`, `region`,
`domain_name`, `subdomain`) must be set to the same value in each.

Infra-only:

| Variable              | What it is                                            |
| --------------------- | ----------------------------------------------------- |
| `kubeconfig_admin_ip` | Your public IPv4 in CIDR form (e.g. `203.0.113.5/32`) |

Find your public IP with `curl -s ifconfig.me` and append `/32`.

## Provision

Apply the bootstrap layer first to create the hosted zone:

```sh
cd bootstrap
terraform init
terraform apply
```

Take the `name_servers` output and set them as NS records for the subdomain
at your registrar. This delegation only needs to happen once; the records
stay valid across rebuilds of `infra/` and `apps/`.

Then apply infra, then apps:

```sh
cd ../infra
terraform init
terraform apply

cd ../apps
terraform init
terraform apply
```

`infra/` reads `zone_id` from bootstrap's state for ACM validation; `apps/`
reads cluster endpoint/CA/OIDC from infra's state and `zone_id` from
bootstrap's. Each layer's `terraform_remote_state` lookup fails until its
upstream layer has applied at least once.

## Use the cluster

```sh
cd infra
$(terraform output -raw kubeconfig_update_command)
kubectl get pods -A

cd ../apps
curl "$(terraform output -raw podinfo_url)"
```

## Tear down

Destroy order is now operational: there is no cross-state `depends_on`, so
the layers must come down in reverse. Destroy `apps/` first so the Ingress
and Helm releases release their ALB and IRSA dependencies *before* infra
removes NAT and IAM:

```sh
cd apps  && terraform destroy
cd ../infra && terraform destroy
```

If destroy hangs in `apps/` on load balancers or ENIs, delete the Ingress
first so the ALB controller cleans up its out-of-band AWS resources:

```sh
kubectl delete ingress -n podinfo podinfo
```

To remove the hosted zone too (forces you to re-delegate at the registrar
next time):

```sh
cd bootstrap
terraform destroy
```

## Layout

```
bootstrap/         # Route 53 hosted zone (long-lived state)

infra/             # VPC, EKS, ACM (AWS provider only)
  versions.tf      # backend + required providers
  main.tf          # provider configuration
  variables.tf
  locals.tf        # shared tags
  outputs.tf       # cluster endpoint/CA/OIDC, vpc_id, ACM ARN, region
  networking.tf    # VPC, subnets, IGW, NAT, route tables
  eks.tf           # EKS module invocation
  dns.tf           # bootstrap remote state + ACM certificate
  modules/eks/     # EKS cluster + managed node group + IAM + add-ons + OIDC

apps/              # In-cluster workloads (kubernetes + helm providers)
  versions.tf
  main.tf          # provider configurations (k8s/helm wired off infra state)
  variables.tf
  locals.tf
  outputs.tf       # podinfo_url
  data.tf          # terraform_remote_state for infra and bootstrap
  load-balancer.tf # AWS Load Balancer Controller (IRSA + Helm)
  external-dns.tf  # ExternalDNS (IRSA + Helm)
  ingress.tf       # Ingress object for podinfo
  podinfo.tf       # podinfo Helm release
  modules/irsa-role/ # Reusable IAM role + policy + service account for IRSA
```
