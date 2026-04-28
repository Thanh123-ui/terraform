############################################
# LOCALS
############################################
locals {
  db_name = "hospital_booking"
  db_port = 3306
  cors_origin = "https://${aws_cloudfront_distribution.app_cdn.domain_name}"
}

############################################
# USER DATA TEMPLATE
############################################
locals {
  user_data = templatefile("${path.module}/user_data.sh", {
    github_repo_url = data.aws_ssm_parameter.github_repo_url.value
    db_host         = aws_db_instance.mysql.address
    db_port         = local.db_port
    db_name         = local.db_name
    db_username     = data.aws_ssm_parameter.db_username.value
    db_password     = data.aws_ssm_parameter.db_password.value
    app_port        = var.app_port
    cors_origin     = local.cors_origin
    email_provider  = var.email_provider
    aws_region      = var.aws_region
    ses_region      = var.ses_region
    email_from      = data.aws_ssm_parameter.email_from.value
  })
}
