############################################
# OUTPUTS
############################################
output "website_url" {
  value = "http://${aws_lb.app_alb.dns_name}"
}

output "alb_dns_name" {
  value = aws_lb.app_alb.dns_name
}

output "rds_endpoint" {
  value = aws_db_instance.mysql.address
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.app_cdn.domain_name
}