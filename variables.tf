variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "hospital-booking"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# key_name, db_username, db_password, github_repo_url, email_from
# được lấy tự động từ AWS SSM Parameter Store (xem data.tf)
# Không cần khai báo ở đây nữa để tránh lộ thông tin nhạy cảm.

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "enable_nat_gateway" {
  type    = bool
  default = false
}

variable "enable_waf" {
  type    = bool
  default = false
}

variable "waf_rate_limit" {
  type    = number
  default = 100
}

variable "app_port" {
  description = "Port nginx/frontend expose ra ngoài. ALB Target Group trỏ vào đây."
  type        = number
  default     = 80
}

# ─── Email / AWS SES ────────────────────────────────────────────────────────
# email_provider = "ethereal" → chế độ test (không gửi mail thật)
# email_provider = "ses"      → production (cần SES Sandbox được duyệt)
variable "email_provider" {
  description = "Email provider: 'ethereal' (test local) or 'ses' (AWS SES production)"
  type        = string
  default     = "ses"
}

variable "ses_region" {
  description = "AWS SES region"
  type        = string
  default     = "us-east-1"
}
