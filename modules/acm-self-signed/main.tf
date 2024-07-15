#
# Demo App
#
# ACM - Self Signed Demo Cert for HTTPS
#

resource "tls_private_key" "dummy" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "dummy" {
  private_key_pem = tls_private_key.dummy.private_key_pem

  subject {
    common_name  = var.common_name
    organization = var.organization
  }

  validity_period_hours = var.validity_period_hours

  allowed_uses = [
    "server_auth"
  ]
}

resource "aws_acm_certificate" "cert" {
  private_key      = tls_private_key.dummy.private_key_pem
  certificate_body = tls_self_signed_cert.dummy.cert_pem

  tags = var.tags
}
