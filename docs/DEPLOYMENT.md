# Deployment Guide

This guide covers the deployment paths supported by this Terraform repository.

## Prerequisites

- Terraform >= 1.5.0
- AWS CLI v2
- AWS credentials with permission to manage the required services
- Existing S3 backend bucket configured in `environments/prod/backend.tf`
- ACM certificate in `us-east-1` if using a custom CloudFront domain
- SES verified sender email
- Existing EC2 key pair name stored in SSM Parameter Store

## Required SSM Parameters

Create these before running `terraform plan` or `terraform apply`:

```bash
aws ssm put-parameter --name "/hospital/prod/db_username" --value "admin" --type String --overwrite

aws ssm put-parameter --name "/hospital/prod/db_password" --value "REPLACE_WITH_STRONG_PASSWORD" --type SecureString --overwrite

aws ssm put-parameter --name "/hospital/prod/key_name" --value "your-keypair-name" --type String --overwrite

aws ssm put-parameter --name "/hospital/prod/github_repo_url" --value "https://github.com/ChiThanh-cloud/webhospital-booking.git" --type String --overwrite

aws ssm put-parameter --name "/hospital/prod/email_from" --value "your-verified-ses-email@example.com" --type String --overwrite
```

## Terraform Deployment

Run Terraform from the production environment directory:

```bash
cd environments/prod
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

Useful outputs:

- `alb_dns_name`
- `cloudfront_domain`
- `db_address`
- `github_actions_role_arn`

## EC2 Bootstrap Deployment

The EC2 Launch Template uses `modules/app-cluster/user_data.sh`.

During startup, the instance:

1. Installs required packages.
2. Clones the main application repository from the SSM-provided URL.
3. Fetches database username and password from SSM.
4. Writes `backend/.env` on the EC2 instance.
5. Attempts to seed `database/schema.sql`.
6. Runs the production Docker Compose stack.

The script expects the main app repository to contain:

- `backend/`
- `database/schema.sql`
- `docker-compose.prod.yml`

## Docker Deployment

Docker Compose deployment is referenced through the main application repository. This Terraform repository does not include `docker-compose.prod.yml`, so Docker commands should be run from `webhospital-booking` after cloning that repository.

Expected production command on EC2:

```bash
docker-compose -f docker-compose.prod.yml up --build -d
```

## DNS and Domain

After Terraform creates CloudFront, point the custom domain to the `cloudfront_domain` output using a DNS CNAME record.

If `custom_domain` is empty or no ACM certificate is configured, CloudFront can use its default domain and certificate.

## Destroy

For demo cleanup:

```bash
cd environments/prod
terraform destroy
```

Before destroying a real environment, review RDS backup requirements. The current database module uses `skip_final_snapshot = true`.
