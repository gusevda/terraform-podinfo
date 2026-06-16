# IAM policy

data "http" "alb_controller_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.8.1/docs/install/iam_policy.json"
}

resource "aws_iam_policy" "alb_controller" {
  name   = "${var.name}-alb-controller"
  policy = data.http.alb_controller_policy.response_body
}

module "alb_controller_irsa" {
  source = "./modules/irsa-role"

  name = "${var.name}-alb-controller"
  namespace = "kube-system"
  service_account_name = "aws-load-balancer-controller"
  policy_arn = aws_iam_policy.alb_controller.arn
  oidc_provider_arn = aws_iam_openid_connect_provider.eks.arn
  oidc_provider_url = aws_iam_openid_connect_provider.eks.url
}

resource "helm_release" "alb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.8.1"             # matches v2.8.1 of the controller
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = aws_eks_cluster.main.name
  }
  set {
    name  = "serviceAccount.create"
    value = "false"
  }
  set {
    name  = "serviceAccount.name"
    value = module.alb_controller_irsa.service_account_name
  }
  set {
    name  = "region"
    value = var.region
  }
  set {
    name  = "vpcId"
    value = aws_vpc.main.id
  }

  depends_on = [aws_eks_node_group.main]
}
