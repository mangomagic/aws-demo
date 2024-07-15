#
# Demo App
#
# Outputs
#
output "https_endpoint" {
  value = format("https://%s", module.alb.this_lb_dns_name)
}