############################################
# CLOUDFRONT DISTRIBUTION
############################################
resource "aws_cloudfront_distribution" "app_cdn" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "CloudFront for ${var.project_name}-${var.environment}"

  # Custom domain
  aliases = ["nguyenchithanhit.id.vn"]

  origin {
    domain_name = aws_lb.app_alb.dns_name
    origin_id   = "app-alb-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "app-alb-origin"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = true
      headers      = ["Authorization", "Origin", "Host", "Content-Type", "Accept", "Access-Control-Request-Method", "Access-Control-Request-Headers"]

      cookies {
        forward = "all"
      }
    }

    min_ttl     = 0
    default_ttl = 60
    max_ttl     = 300
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Dùng ACM Certificate đã tạo (us-east-1) để bật HTTPS cho domain
  viewer_certificate {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:216938125549:certificate/2f1c625d-ad4c-426e-9bf2-94d26eee19ef"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  depends_on = [
    aws_lb_listener.http
  ]
}
