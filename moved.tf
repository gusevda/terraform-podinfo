moved {
  from = aws_iam_role.alb_controller
  to = module.alb_controller_irsa.aws_iam_role.this
}

moved {
  from = aws_iam_role_policy_attachment.alb_controller
  to = module.alb_controller_irsa.aws_iam_role_policy_attachment.this
}

moved {
  from = kubernetes_service_account.alb_controller
  to = module.alb_controller_irsa.kubernetes_service_account.this
}

moved {
  from = aws_iam_role.external_dns
  to = module.external_dns_irsa.aws_iam_role.this
}

moved {
  from = aws_iam_role_policy_attachment.external_dns
  to = module.external_dns_irsa.aws_iam_role_policy_attachment.this
}

moved {
  from = kubernetes_service_account.external_dns
  to = module.external_dns_irsa.kubernetes_service_account.this
}

# EKS module extraction

moved {
  from = aws_iam_role.cluster
  to   = module.eks.aws_iam_role.cluster
}

moved {
  from = aws_iam_role_policy_attachment.cluster_policy
  to   = module.eks.aws_iam_role_policy_attachment.cluster_policy
}

moved {
  from = aws_eks_cluster.main
  to   = module.eks.aws_eks_cluster.main
}

moved {
  from = aws_iam_role.node
  to   = module.eks.aws_iam_role.node
}

moved {
  from = aws_iam_role_policy_attachment.node_worker
  to   = module.eks.aws_iam_role_policy_attachment.node_worker
}

moved {
  from = aws_iam_role_policy_attachment.node_cni
  to   = module.eks.aws_iam_role_policy_attachment.node_cni
}

moved {
  from = aws_iam_role_policy_attachment.node_ecr
  to   = module.eks.aws_iam_role_policy_attachment.node_ecr
}

moved {
  from = aws_eks_node_group.main
  to   = module.eks.aws_eks_node_group.main
}

moved {
  from = aws_iam_openid_connect_provider.eks
  to   = module.eks.aws_iam_openid_connect_provider.eks
}

moved {
  from = aws_eks_addon.vpc_cni
  to   = module.eks.aws_eks_addon.vpc_cni
}

moved {
  from = aws_eks_addon.coredns
  to   = module.eks.aws_eks_addon.coredns
}

moved {
  from = aws_eks_addon.kube_proxy
  to   = module.eks.aws_eks_addon.kube_proxy
}
