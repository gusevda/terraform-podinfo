resource "kubernetes_ingress_v1" "podinfo" {
  metadata {
    name      = "podinfo"
    namespace = "podinfo"
    annotations = {
      "alb.ingress.kubernetes.io/scheme"            = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"       = "ip"
      "alb.ingress.kubernetes.io/listen-ports"      = jsonencode([{ HTTP = 80 }, { HTTPS = 443 }])
      "alb.ingress.kubernetes.io/ssl-redirect"      = "443"
      "alb.ingress.kubernetes.io/certificate-arn"   = aws_acm_certificate_validation.podinfo.certificate_arn
      "alb.ingress.kubernetes.io/healthcheck-path"  = "/healthz"
      "alb.ingress.kubernetes.io/healthcheck-port"  = "9898"
      "external-dns.alpha.kubernetes.io/hostname"   = var.subdomain
    }
  }

  spec {
    ingress_class_name = "alb"

    rule {
      host = var.subdomain
      http {
        path {
          path     = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "podinfo"
              port { number = 9898 }
            }
          }
        }
      }
    }
  }

  depends_on = [
    helm_release.podinfo,
    helm_release.alb_controller,
    helm_release.external_dns,
    aws_acm_certificate_validation.podinfo,
  ]
}
