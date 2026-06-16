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
