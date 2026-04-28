data "aws_caller_identity" "current" {}

############################################
# IAM ROLE FOR EC2 BACKEND
############################################
resource "aws_iam_role" "backend_role" {
  name = "${var.project_name}-${var.environment}-app-server"
  description = "EC2 backend role. Enables SES email sending and secure keyless SSH via AWS SSM Session Manager."

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-app-server"
    Project     = var.project_name
    Environment = var.environment
  }
}

############################################
# ATTACH MANAGED POLICY FOR SSM
############################################
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.backend_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

############################################
# INLINE POLICY FOR SES SEND EMAIL
############################################
resource "aws_iam_role_policy" "ses_send" {
  name = "${var.project_name}-${var.environment}-ses-send"
  role = aws_iam_role.backend_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SendEmailFromVerifiedIdentity"
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = "arn:aws:ses:${var.ses_region}:${data.aws_caller_identity.current.account_id}:identity/${var.email_from}"
      },
      {
        Sid    = "ReadSesQuota"
        Effect = "Allow"
        Action = [
          "ses:GetSendQuota",
          "ses:GetSendStatistics"
        ]
        Resource = "*"
      }
    ]
  })
}

############################################
# IAM INSTANCE PROFILE
############################################
resource "aws_iam_instance_profile" "backend_profile" {
  name = "${var.project_name}-${var.environment}-app-server-profile"
  role = aws_iam_role.backend_role.name
}
