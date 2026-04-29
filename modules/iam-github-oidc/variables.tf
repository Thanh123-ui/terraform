variable "name_prefix" {
  description = "Naming prefix: <project>-<environment>"
  type        = string
}

variable "github_repo" {
  description = "GitHub repo theo định dạng 'owner/repo-name'. Ví dụ: Thanh123-ui/terraform"
  type        = string
}

variable "aws_region" {
  description = "AWS Region để build ARN cho DynamoDB lock table"
  type        = string
  default     = "us-east-1"
}

variable "tf_state_bucket" {
  description = "Tên S3 Bucket chứa Terraform State"
  type        = string
}

variable "tf_lock_table" {
  description = "Tên DynamoDB Table dùng để State Locking"
  type        = string
}
