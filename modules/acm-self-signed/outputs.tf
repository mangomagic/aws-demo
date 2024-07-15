#
# Demo App - ACM Self Signed
#
# Outputs
#

output "acm_arn" {
  description = "Self Signed ACM certificate ARN"

  value = aws_acm_certificate.cert.arn
}