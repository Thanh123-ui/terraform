# Project Summary

## 3-Line Summary

Hospital Booking System is a full-stack healthcare appointment booking project with a separate AWS Infrastructure as Code repository.
This Terraform repo provisions the cloud architecture needed to run the application with EC2, ALB, RDS MySQL, CloudFront, IAM, SSM, SES, and optional WAF.
The project is documented for recruiter review, fresher cloud interviews, and research/demo defense.

## Architecture Summary

```text
Client / Mobile App -> CloudFront -> ALB -> EC2 Auto Scaling Group -> Docker Compose app -> RDS MySQL
```

The infrastructure separates public entry points, application compute, database access, IAM permissions, and runtime secrets. EC2 instances pull the main application from GitHub and run it through Docker Compose.

## Tech Stack

| Area | Technology |
| --- | --- |
| Infrastructure | Terraform, AWS provider |
| Cloud | AWS EC2, ALB, Auto Scaling, RDS MySQL, CloudFront, WAF, IAM, SSM, SES |
| Deployment | EC2 user data, Docker, Docker Compose |
| Application | React frontend and Node.js backend in `ChiThanh-cloud/webhospital-booking` |
| Database | MySQL / RDS MySQL 8.0 |

## Key Responsibilities

- Designed AWS infrastructure modules for network, IAM, database, application cluster, CDN/WAF, and GitHub OIDC.
- Configured RDS MySQL with restricted security group access from EC2.
- Automated EC2 bootstrap to clone the app repository, fetch runtime secrets, seed schema, and run Docker Compose.
- Documented architecture, deployment, security, troubleshooting, and future improvements.
- Avoided committing secrets by using SSM Parameter Store for runtime configuration.

## CV Bullet

Hospital Booking System - AWS Infrastructure with Terraform

- Designed a full-stack hospital booking deployment architecture with frontend, backend API, database, and AWS cloud infrastructure.
- Provisioned AWS components such as EC2, ALB, CloudFront, optional WAF, IAM, RDS MySQL, security groups, and SSM Parameter Store using Terraform.
- Documented deployment flow, security considerations, environment configuration, and troubleshooting steps for recruiter and technical review.

## Interview Talking Points

- Why Terraform modules make infrastructure easier to explain and reuse.
- How ALB, EC2, and RDS security groups restrict traffic between layers.
- Why SSM Parameter Store is safer than committing secrets or using static keys.
- How EC2 `user_data.sh` automates application bootstrap.
- What tradeoffs were made for demo scope, such as using the default VPC and disabling deletion protection.
- How this design could evolve into a production-grade private subnet architecture.

## Known Limitations / Future Improvements

- Uses AWS default VPC instead of a custom public/private subnet design.
- WAF is optional and disabled by default.
- RDS deletion protection and final snapshot are disabled for easy demo cleanup.
- Terraform state can still contain the RDS password because Terraform manages the database resource.
- CI/CD workflow files are not present in this Terraform repository, although an OIDC role module exists.
- Add monitoring, alerts, log retention, backup restore testing, security scanning, and automated smoke tests.
