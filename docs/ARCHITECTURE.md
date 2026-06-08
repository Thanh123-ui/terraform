# Architecture

This repository defines the AWS infrastructure for the Hospital Booking System. The application source code is kept in the main repository:

<https://github.com/ChiThanh-cloud/webhospital-booking>

## System Context

```text
User browser / mobile client
        |
        v
CloudFront
        |
        v
Application Load Balancer
        |
        v
EC2 Auto Scaling Group
        |
        v
Docker Compose application stack
        |
        v
RDS MySQL 8.0
```

The Terraform code provisions the cloud infrastructure and bootstraps EC2 instances. The actual frontend, backend, database schema, and Docker Compose production file are pulled from the main application repository during EC2 startup.

## Request Flow

1. A user opens the application through the custom domain or CloudFront domain.
2. CloudFront receives the request and redirects viewers to HTTPS.
3. CloudFront forwards dynamic application traffic to the Application Load Balancer.
4. The ALB forwards traffic to healthy EC2 instances on the configured `app_port`.
5. Docker Compose runs the application services on EC2.
6. The backend API connects to RDS MySQL using credentials fetched from SSM Parameter Store.

## AWS Components

| Component | Terraform location | Purpose |
| --- | --- | --- |
| Default VPC and subnets | `modules/network` | Network base for demo deployment |
| Security Groups | `modules/network` | Restrict traffic between ALB, EC2, and RDS |
| RDS MySQL | `modules/database` | Managed relational database |
| ALB and target group | `modules/app-cluster` | Public entry point and health checks |
| Launch Template | `modules/app-cluster` | EC2 instance configuration and bootstrap script |
| Auto Scaling Group | `modules/app-cluster` | Keeps the app instance running and allows scaling |
| CloudFront | `modules/cdn-waf` | CDN layer and HTTPS viewer policy |
| AWS WAF v2 | `modules/cdn-waf` | Optional managed rules and IP rate limiting on ALB |
| IAM instance profile | `modules/iam` | Runtime permissions for EC2 |
| GitHub OIDC role | `modules/iam-github-oidc` | Keyless CI/CD access from GitHub Actions |
| SSM Parameter Store | `environments/prod/main.tf` data sources | Runtime configuration and secrets |

## Security Boundaries

```text
Internet
  -> ALB security group: inbound HTTP 80
  -> EC2 security group: app port only from ALB security group
  -> RDS security group: MySQL 3306 only from EC2 security group
```

RDS is configured as not publicly accessible. EC2 does not need long-lived AWS keys because it uses an IAM instance profile. Database credentials are read from SSM Parameter Store during bootstrap.

## Current Design Tradeoffs

- The network module uses the AWS default VPC for simplicity.
- WAF is available but disabled by default with `enable_waf = false`.
- RDS deletion protection is disabled and final snapshots are skipped, which is convenient for demos but not recommended for long-lived production.
- Terraform still needs the RDS password to create the database, so the password can appear in Terraform state.
- The EC2 bootstrap writes secrets into a local backend `.env` file for application compatibility.
