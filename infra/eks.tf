module "eks" {
  source = "./modules/eks"

  name = var.name
  kubernetes_version = var.kubernetes_version
  public_access_cidrs = [var.kubeconfig_admin_ip]
  node_instance_type = var.node_instance_type
  subnet_ids = concat(aws_subnet.public[*].id, aws_subnet.private[*].id)
  node_subnet_ids = aws_subnet.private[*].id

  # Pods need NAT egress to pull images, so the node group must wait
  # for the private subnets' default route to exist. Threaded through as
  # an input rather than module-level depends_on — the latter would mark
  # all module outputs unknown at plan time and break the kubernetes/helm
  # providers that consume them.
  node_group_extra_depends_on = concat(
    aws_route_table_association.private[*].id,
    [aws_nat_gateway.main.id],
  )
}
