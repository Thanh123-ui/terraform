# Hospital Booking System - AWS Infrastructure & Full-stack Deployment

Infrastructure as Code for a healthcare appointment booking platform. This repository provisions the AWS side of the Hospital Booking System and documents how the frontend, backend API, database, and deployment flow are intended to run together.

Main application repository: <https://github.com/ChiThanh-cloud/webhospital-booking>

Suggested GitHub description: Full-stack hospital booking system with AWS deployment architecture, Docker, backend API, database, and cloud security documentation.

Suggested topics: `hospital-booking`, `healthcare`, `fullstack`, `aws`, `terraform`, `docker`, `cloud-infrastructure`, `nodejs`, `react`, `mysql`

## Overview

The Hospital Booking System is designed as a full-stack healthcare booking project with patient-facing, doctor/staff, and admin workflows in the main application repository. This Terraform repository focuses on the cloud deployment architecture: AWS networking, compute, database, CDN, optional WAF, IAM roles, SSM-based configuration, and EC2 bootstrap automation.

This is a demo/research infrastructure project, not a fully hardened production system. The documentation calls out current limitations and future improvements where appropriate.

## Key Features

Application features are implemented in the main `webhospital-booking` repository. This infrastructure repository supports the following deployment capabilities:

| Area | Supported by this repo |
| --- | --- |
| Patient | Public web access through CloudFront and ALB for the booking application |
| Doctor/Staff | Backend API deployment support through Docker Compose on EC2 |
| Admin | Backend/database deployment support for application management features |
| Cloud infrastructure | Terraform modules for network security groups, EC2 Auto Scaling, ALB, RDS MySQL, CloudFront, optional WAF, IAM, and GitHub OIDC |
| Runtime configuration | AWS SSM Parameter Store for database credentials, repo URL, key pair name, and email sender |

## Tech Stack

| Layer | Technology |
| --- | --- |
| Frontend | React app in the main `webhospital-booking` repository, deployed by `docker-compose.prod.yml` during EC2 bootstrap |
| Backend | Node.js API in the main `webhospital-booking` repository, deployed by `docker-compose.prod.yml` during EC2 bootstrap |
| Mobile | Not present in this Terraform repository |
| Database | AWS RDS MySQL 8.0 |
| Cloud / Infrastructure | AWS VPC default network lookup, Security Groups, ALB, EC2 Launch Template, Auto Scaling Group, RDS, CloudFront, optional AWS WAF v2, IAM, SSM Parameter Store, SES |
| DevOps / Deployment | Terraform >= 1.5, AWS provider ~> 6.0, EC2 `user_data.sh`, Docker, Docker Compose, GitHub Actions OIDC IAM role |

## Architecture

```text
Client / Mobile App
        |
        v
CloudFront CDN
        |
        v
Application Load Balancer
        |
        v
EC2 Auto Scaling Group
        |
        v
Docker Compose: frontend + backend API
        |
        v
RDS MySQL 8.0
```

Security boundaries implemented in Terraform:

- ALB security group accepts public HTTP traffic on port 80.
- EC2 security group accepts app traffic only from the ALB security group.
- RDS security group accepts MySQL traffic only from the EC2 security group.
- EC2 uses an IAM instance profile for SSM Session Manager, SSM Parameter Store reads, SES email sending, and CloudWatch Logs writes.
- CloudFront redirects viewers to HTTPS when an ACM certificate/custom domain is configured.
- WAF is implemented as an optional ALB protection layer and is disabled by default to control demo cost.

More detail: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)

## Repository Structure

```text
terraform/
├── environments/
│   └── prod/
│       ├── backend.tf          # S3 remote state backend
│       ├── main.tf             # Production module composition
│       ├── outputs.tf          # Useful infrastructure outputs
│       ├── providers.tf        # Terraform and AWS provider configuration
│       ├── terraform.tfvars    # Non-sensitive production values
│       └── variables.tf        # Production input variables
├── modules/
│   ├── app-cluster/            # ALB, Launch Template, Auto Scaling, user_data.sh
│   ├── cdn-waf/                # CloudFront and optional AWS WAF v2
│   ├── database/               # RDS MySQL and DB subnet group
│   ├── iam/                    # EC2 runtime role, instance profile, IAM policies
│   ├── iam-github-oidc/        # GitHub Actions OIDC IAM role
│   └── network/                # Default VPC lookup and security groups
├── docs/
│   ├── ARCHITECTURE.md
│   ├── DEPLOYMENT.md
│   ├── SECURITY.md
│   ├── TROUBLESHOOTING.md
│   └── images/.gitkeep
├── .env.example                # Example app/runtime environment values
├── .gitignore
├── INFRASTRUCTURE.md           # Research/defense infrastructure notes
├── PROJECT_SUMMARY.md          # CV and interview summary
└── README.md
```

## Local Development

This repository does not contain the frontend/backend source code, so local application development happens in:

```bash
git clone https://github.com/ChiThanh-cloud/webhospital-booking.git
cd webhospital-booking
```

Use the main application repository README for its exact frontend, backend, database, and Docker commands.

For this Terraform repository:

### Prerequisites

- Terraform >= 1.5.0
- AWS CLI v2 configured with an AWS account
- AWS permissions to manage EC2, ALB, Auto Scaling, RDS, CloudFront, WAF, IAM, SSM, SES, and S3 backend resources
- Existing AWS S3 backend bucket matching `environments/prod/backend.tf`
- Existing AWS account resources for ACM certificate, SES verified sender, and EC2 key pair as needed

### Terraform workflow

```bash
git clone https://github.com/ChiThanh-cloud/terraform.git
cd terraform/environments/prod

terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

## Environment Variables

No secrets should be committed to Git. Runtime secrets are expected in AWS SSM Parameter Store.

Required SSM parameters:

| Parameter | Type | Purpose |
| --- | --- | --- |
| `/hospital/prod/db_username` | String | RDS MySQL username |
| `/hospital/prod/db_password` | SecureString | RDS MySQL password |
| `/hospital/prod/key_name` | String | Existing EC2 key pair name |
| `/hospital/prod/github_repo_url` | String | Main app repo URL, for example `https://github.com/ChiThanh-cloud/webhospital-booking.git` |
| `/hospital/prod/email_from` | String | SES verified sender email |

Example local app variables are documented in [.env.example](.env.example). Do not commit real `.env` files.

## Deployment

### AWS deployment with Terraform

From `environments/prod`:

```bash
terraform init
terraform plan
terraform apply
```

The deployment provisions:

- Security groups in the AWS default VPC
- RDS MySQL 8.0
- EC2 Launch Template and Auto Scaling Group
- Application Load Balancer with `/health` target group health check
- CloudFront distribution
- Optional AWS WAF v2 on the ALB
- IAM roles for EC2 runtime and GitHub Actions OIDC

### EC2 bootstrap deployment

The EC2 instance runs [modules/app-cluster/user_data.sh](modules/app-cluster/user_data.sh). The script:

1. Installs Git, Docker, Docker Compose, MariaDB client, and AWS CLI.
2. Clones `https://github.com/ChiThanh-cloud/webhospital-booking.git` from the SSM-provided repo URL.
3. Fetches database credentials from SSM Parameter Store.
4. Writes the backend runtime `.env` file on the EC2 instance.
5. Seeds `database/schema.sql` if available in the app repository.
6. Runs `docker-compose -f docker-compose.prod.yml up --build -d`.

### Docker Compose deployment

Docker Compose deployment is expected to come from the main application repository through `docker-compose.prod.yml`. That file is referenced by `user_data.sh` but is not stored in this Terraform repository.

More detail: [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)

## Security Considerations

- Secrets are stored in SSM Parameter Store instead of this repository.
- EC2 reads runtime secrets through its IAM instance profile.
- Database access is restricted to the EC2 security group.
- Public inbound access is limited to the ALB security group.
- WAF rules are available but disabled by default through `enable_waf = false`.
- RDS is not publicly accessible.
- SES sending is scoped to the configured verified identity.
- JWT secrets are generated during EC2 bootstrap and written to the server-side `.env` file.

Recommended improvements:

- Move from default VPC to custom public/private subnets.
- Enable RDS deletion protection and final snapshots for long-lived environments.
- Store or rotate JWT secrets through SSM or Secrets Manager instead of generating them on each bootstrap.
- Add HTTPS listener directly on ALB if bypassing CloudFront is required.
- Add CI checks such as `terraform fmt`, `terraform validate`, `tflint`, `tfsec`, or Checkov.

More detail: [docs/SECURITY.md](docs/SECURITY.md)

## Screenshots / Evidence

No screenshots are included in this repository yet.

Add evidence images to `docs/images/` and reference them here, for example:

```md
![CloudFront distribution](docs/images/cloudfront-distribution.png)
![Terraform apply output](docs/images/terraform-apply.png)
![Application homepage](docs/images/application-homepage.png)
```

Suggested evidence to add:

- Terraform `plan` or `apply` output with sensitive values hidden
- AWS ALB target group healthy status
- CloudFront distribution status
- RDS private database configuration
- Application homepage and booking workflow screenshots

## What I Learned

- Designed a cloud deployment path for a real full-stack web application.
- Separated application code, runtime configuration, database, and infrastructure concerns.
- Used Terraform modules to make AWS resources easier to explain and maintain.
- Applied basic AWS security layers with IAM roles, SSM Parameter Store, security groups, private RDS access, and optional WAF.
- Practiced documenting deployment, troubleshooting, and limitations for recruiter and technical review.

## Future Improvements

- Replace default VPC usage with a custom VPC, public/private subnets, NAT gateways, and explicit route tables.
- Clean up Terraform modules further and add environment reuse for dev/staging/prod.
- Add HTTPS/domain setup steps for ALB and CloudFront validation.
- Add CloudWatch dashboards, alarms, structured logs, and log retention policies.
- Add automated backup and restore documentation.
- Harden the CI/CD pipeline with policy checks and security scanning.
- Harden RDS with private subnet design, final snapshots, deletion protection, and credential rotation.
- Add automated infrastructure and smoke tests.

## Related Documents

- [Infrastructure notes](INFRASTRUCTURE.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Deployment guide](docs/DEPLOYMENT.md)
- [Security guide](docs/SECURITY.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Project summary for CV/interview](PROJECT_SUMMARY.md)
