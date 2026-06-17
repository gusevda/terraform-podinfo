resource "helm_release" "podinfo" {
  name             = "podinfo"
  repository       = "https://stefanprodan.github.io/podinfo"
  chart            = "podinfo"
  version          = var.podinfo_chart_version
  namespace        = "podinfo"
  create_namespace = true

  values = [yamlencode({
    replicaCount = 2
    ui = {
      color = "#34577c"
      message = "Served from EKS in ${var.region}"
    }
    ingress = {
      enabled = false       # we'll define the Ingress ourselves, separately
    }
    resources = {
      requests = { cpu = "50m",  memory = "64Mi"  }
      limits   = { cpu = "200m", memory = "128Mi" }
    }
  })]
}
