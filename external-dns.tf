# IAM policy

data "aws_iam_policy_document" "external_dns" {
  statement {
    actions   = ["route53:ChangeResourceRecordSets"]
    resources = ["arn:aws:route53:::hostedzone/${local.zone_id}"]
  }
  statement {
    actions   = ["route53:ListHostedZones", "route53:ListResourceRecordSets", "route53:ListTagsForResource"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "external_dns" {
  name   = "${var.name}-external-dns"
  policy = data.aws_iam_policy_document.external_dns.json
}

module "external_dns_irsa" {
  source = "./modules/irsa-role"

  name                 = "${var.name}-external-dns"
  namespace            = "kube-system"
  service_account_name = "external-dns"
  policy_arn           = aws_iam_policy.external_dns.arn
  oidc_provider_arn    = module.eks.oidc_provider_arn
  oidc_provider_url    = module.eks.oidc_provider_url
}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  version    = "1.14.5"
  namespace  = "kube-system"

  set {
    name  = "serviceAccount.create"
    value = "false"
  }
  set {
    name  = "serviceAccount.name"
    value = module.external_dns_irsa.service_account_name
  }
  set {
    name  = "provider"
    value = "aws"
  }
  set {
    name  = "policy"
    value = "sync"      # delete records when their owning Ingress goes away
  }
  set {
    name  = "txtOwnerId"
    value = var.name    # encodes ownership in TXT records so two clusters don't fight
  }
  set {
    name  = "domainFilters[0]"
    value = var.domain_name
  }

  depends_on = [module.eks]
}
