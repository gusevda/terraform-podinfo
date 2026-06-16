# terraform-podinfo

Terraform configuration that provisions an EKS cluster on AWS and deploys
[podinfo](https://github.com/stefanprodan/podinfo) behind an HTTPS-terminated
ALB with a Route 53-managed DNS record.

## What gets created

- VPC across two AZs (public + private subnets, IGW, single NAT gateway)
- EKS cluster with a managed node group in the private subnets
- Core EKS add-ons: `vpc-cni`, `coredns`, `kube-proxy`
- IRSA (OIDC provider + per-workload IAM roles)
- AWS Load Balancer Controller (Helm)
- ExternalDNS (Helm), reconciling Ingress hosts into Route 53
- Route 53 hosted zone for the chosen subdomain + ACM certificate (DNS-validated)
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

## Provision

```sh
terraform init
terraform plan
terraform apply
```

The first apply produces `podinfo_zone_nameservers`. Set those as NS records
for the subdomain at your registrar; once DNS propagates, ACM validation
finishes and the Ingress comes online.

## Use the cluster

```sh
$(terraform output -raw kubeconfig_update_command)
kubectl get pods -A
curl "$(terraform output -raw podinfo_url)"
```

## Tear down

```sh
terraform destroy
```

If destroy hangs on load balancers or ENIs, delete the Ingress first so the
ALB controller cleans up its out-of-band AWS resources:

```sh
kubectl delete ingress -n podinfo podinfo
```

## Layout

```
versions.tf        # backend + required providers
main.tf            # provider configurations
variables.tf       # input variables
locals.tf          # shared tags
outputs.tf         # stack outputs
networking.tf      # VPC, subnets, IGW, NAT, route tables
cluster.tf         # EKS cluster + managed node group + IAM
addons.tf          # vpc-cni / coredns / kube-proxy
irsa.tf            # OIDC provider for IRSA
load-balancer.tf   # AWS Load Balancer Controller (IAM + Helm)
external-dns.tf    # ExternalDNS (IAM + Helm)
dns.tf             # Route 53 zone + ACM certificate
ingress.tf         # Ingress object for podinfo
podinfo.tf         # podinfo Helm release
```
