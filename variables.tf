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

variable "key_name" {
  description = "EC2 Key Pair name"
  type        = string
}

variable "db_username" {
  description = "RDS master username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}

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

variable "github_repo_url" {
  description = "Public GitHub repo URL"
  type        = string
}

variable "app_port" {
  description = "Node.js app port"
  type        = number
  default     = 3000
}

# ─── Email / AWS SES ────────────────────────────────────────────────────────
# email_provider = "ethereal" → chế độ test (không gửi mail thật)
# email_provider = "ses"      → production (cần SES Sandbox được duyệt)
variable "email_provider" {
  description = "Email provider: 'ethereal' (test local) or 'ses' (AWS SES production)"
  type        = string
  default     = "ethereal"
}

variable "ses_region" {
  description = "AWS SES region (chỉ cần khi email_provider = 'ses')"
  type        = string
  default     = ""
}

variable "ses_access_key_id" {
  description = "AWS SES IAM Access Key ID (chỉ cần khi email_provider = 'ses')"
  type        = string
  default     = ""
  sensitive   = true
}

variable "ses_secret_access_key" {
  description = "AWS SES IAM Secret Access Key (chỉ cần khi email_provider = 'ses')"
  type        = string
  default     = ""
  sensitive   = true
}

variable "email_from" {
  description = "Địa chỉ email gửi đi (chỉ cần khi email_provider = 'ses')"
  type        = string
  default     = ""
}
