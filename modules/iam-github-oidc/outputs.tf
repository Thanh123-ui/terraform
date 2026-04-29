output "github_actions_role_arn" {
  description = "ARN của Role — Copy giá trị này vào GitHub Secrets với tên: AWS_ROLE_ARN"
  value       = aws_iam_role.github_actions.arn
}

output "github_actions_role_name" {
  description = "Tên của IAM Role"
  value       = aws_iam_role.github_actions.name
}

output "oidc_provider_arn" {
  description = "ARN của GitHub OIDC Provider đã tạo trên AWS"
  value       = aws_iam_openid_connect_provider.github.arn
}
