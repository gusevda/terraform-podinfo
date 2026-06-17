# terraform-podinfo

Terraform configuration that provisions an EKS cluster on AWS and deploys
[podinfo](https://github.com/stefanprodan/podinfo) behind an HTTPS-terminated
ALB with a Route 53-managed DNS record.

The stack is split in two layers so the hosted zone (and its nameservers,
which need to be delegated at the registrar once) survives `terraform destroy`
of the main stack:

- `bootstrap/` — Route 53 hosted zone. Long-lived.
- root — VPC, EKS, add-ons, podinfo. Disposable. Reads the zone ID from the
  bootstrap layer via `terraform_remote_state`.

## What gets created

**Bootstrap layer**

- Route 53 hosted zone for the chosen subdomain

**Main stack**

- VPC across two AZs (public + private subnets, IGW, single NAT gateway)
- EKS cluster with a managed node group in the private subnets
- Core EKS add-ons: `vpc-cni`, `coredns`, `kube-proxy`
- IRSA (OIDC provider + per-workload IAM roles)
- AWS Load Balancer Controller (Helm)
- ExternalDNS (Helm), reconciling Ingress hosts into Route 53
- ACM certificate (DNS-validated against the bootstrapped zone)
- podinfo Helm release and a Kubernetes Ingress that fronts it via the ALB

## Prerequisites

- Terraform `>= 1.5`
- An AWS account and a named CLI profile with admin-equivalent permissions
- A registered domain you control (delegation to Route 53 happens via the
  nameservers this stack outputs)
- `kubectl` for poking at the cluster after apply

## Configure

Copy the example tfvars file and fill it in:

```sh
cp terraform.tfvars.example terraform.tfvars
```

At minimum, set:

| Variable              | What it is                                                  |
| --------------------- | ----------------------------------------------------------- |
| `profile`             | AWS CLI profile name                                        |
| `kubeconfig_admin_ip` | Your public IPv4 in CIDR form (e.g. `203.0.113.5/32`)       |
| `domain_name`         | Hosted zone Terraform will manage                           |
| `subdomain`           | Hostname where podinfo will be served                       |

Find your public IP with `curl -s ifconfig.me` and append `/32`.

The `bootstrap/` layer reuses `profile` and `subdomain` — see
`bootstrap/terraform.tfvars`.

## Provision

Apply the bootstrap layer first to create the hosted zone:

```sh
cd bootstrap
terraform init
terraform apply
```

Take the `nameservers` output and set them as NS records for the subdomain at
your registrar. This delegation only needs to happen once; the records stay
valid across rebuilds of the main stack.

Then apply the main stack:

```sh
cd ..
terraform init
terraform plan
terraform apply
```

The main stack reads `zone_id` from the bootstrap layer's remote state. Once
DNS propagates, ACM validation finishes and the Ingress comes online.

## Use the cluster

```sh
$(terraform output -raw kubeconfig_update_command)
kubectl get pods -A
curl "$(terraform output -raw podinfo_url)"
```

## Tear down

Destroy the main stack (the hosted zone in `bootstrap/` stays put, so the
delegation at the registrar survives):

```sh
terraform destroy
```

If destroy hangs on load balancers or ENIs, delete the Ingress first so the
ALB controller cleans up its out-of-band AWS resources:

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
versions.tf        # backend + required providers
main.tf            # provider configurations
variables.tf       # input variables
locals.tf          # shared tags
outputs.tf         # stack outputs
networking.tf      # VPC, subnets, IGW, NAT, route tables
eks.tf             # EKS module invocation (cluster, node group, add-ons, OIDC)
load-balancer.tf   # AWS Load Balancer Controller (IRSA + Helm)
external-dns.tf    # ExternalDNS (IRSA + Helm)
dns.tf             # bootstrap remote state + ACM certificate
ingress.tf         # Ingress object for podinfo
podinfo.tf         # podinfo Helm release

bootstrap/         # Long-lived Route 53 hosted zone (separate state)

modules/
  eks/             # EKS cluster + managed node group + IAM + add-ons + OIDC
  irsa-role/       # Reusable IAM role + policy + service account for IRSA
```
