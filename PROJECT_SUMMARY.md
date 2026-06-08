# Project Summary

## Summary

Hospital Booking System is a full-stack healthcare appointment booking project with AWS infrastructure documented and provisioned through Terraform.
The application repository is `ChiThanh-cloud/webhospital-booking`, while this Terraform code describes the cloud deployment architecture for the project.
The infrastructure is designed for demo, learning, recruiter review, and technical interview discussion.

## Architecture

```text
Client / Mobile App -> CloudFront -> ALB -> EC2 Auto Scaling Group -> Docker Compose app -> RDS MySQL
```

The deployment separates public traffic, application compute, database access, runtime secrets, and IAM permissions. EC2 instances bootstrap the application by cloning the main repository and running the production Docker Compose stack.

## Tech Stack

| Area | Technology |
| --- | --- |
| Infrastructure | Terraform, AWS provider |
| Cloud | EC2, ALB, Auto Scaling, RDS MySQL, CloudFront, optional WAF, IAM, SSM Parameter Store, SES |
| Deployment | EC2 user data, Docker, Docker Compose |
| Application | React frontend and Node.js backend in `ChiThanh-cloud/webhospital-booking` |
| Database | MySQL / RDS MySQL 8.0 |

## Key Responsibilities

- Designed Terraform modules for network, IAM, database, app cluster, CDN/WAF, and GitHub OIDC.
- Configured ALB, EC2 Auto Scaling, and RDS MySQL for a cloud-hosted hospital booking application.
- Restricted database traffic through security groups so RDS accepts MySQL traffic only from EC2.
- Used SSM Parameter Store for runtime configuration instead of committing secrets.
- Automated EC2 bootstrap to clone the app, generate runtime environment variables, seed schema when available, and run Docker Compose.
- Documented deployment, architecture, security notes, troubleshooting, and current limitations.

## CV Bullet

Hospital Booking System - AWS Infrastructure with Terraform

- Designed a full-stack hospital booking deployment architecture with frontend, backend API, database, and AWS cloud infrastructure.
- Provisioned AWS components such as EC2, ALB, CloudFront, optional WAF, IAM, RDS MySQL, security groups, and SSM Parameter Store using Terraform.
- Documented deployment flow, security considerations, environment configuration, and troubleshooting steps for recruiter and technical review.

## Interview Talking Points

- Why Terraform modules make the infrastructure easier to explain and reuse.
- How security groups separate public, application, and database layers.
- Why SSM Parameter Store is safer than committing `.env` secrets.
- How GitHub OIDC avoids long-lived AWS access keys in CI/CD.
- How EC2 `user_data.sh` bootstraps the application with Docker Compose.
- What should be improved before treating the design as production-grade.

## Known Limitations

- Uses the AWS default VPC instead of a custom public/private subnet design.
- WAF is implemented but disabled by default.
- RDS deletion protection and final snapshots are disabled for demo cleanup.
- Terraform state can contain the RDS password because Terraform manages the database resource.
- Additional monitoring, alerting, backup restore testing, and security scanning should be added for production-like environments.
