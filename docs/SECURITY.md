# Security Notes

This project demonstrates security-conscious infrastructure for a demo hospital booking deployment. It is not a complete production hardening baseline.

## Secrets and Environment Variables

- Secrets are not stored in this repository.
- Required runtime secrets are stored in AWS SSM Parameter Store.
- `db_password` should be a SecureString.
- The EC2 instance profile allows the app server to read only the `/hospital/*` SSM namespace.
- The bootstrap script writes a server-side `.env` file on EC2 for compatibility with the current application.

Recommended improvement: move application secret reads directly into the backend runtime or AWS Secrets Manager, then avoid writing long-lived secrets to disk.

## JWT and Authentication

`user_data.sh` generates `JWT_SECRET` and `JWT_REFRESH_SECRET` during EC2 bootstrap. This avoids committing JWT secrets, but it also means secrets can change when instances are recreated.

Recommended improvement: store stable JWT secrets in SSM Parameter Store or AWS Secrets Manager and rotate them intentionally.

## IAM

The EC2 role supports:

- SSM Session Manager access
- SSM Parameter Store reads
- SES email sending from the configured verified identity
- CloudWatch Logs writes

The GitHub OIDC module creates an IAM role that GitHub Actions can assume without long-lived AWS access keys.

Recommended improvement: continue narrowing non-IAM permissions with resource ARNs, tags, and environment-specific boundaries.

## Network Security

Implemented security group flow:

```text
Internet -> ALB: HTTP 80
ALB -> EC2: app port
EC2 -> RDS: MySQL 3306
```

RDS is configured as `publicly_accessible = false`.

Recommended improvement: replace default VPC usage with a custom VPC containing public subnets for ALB and private subnets for EC2/RDS.

## WAF and HTTPS

The `cdn-waf` module supports AWS WAF v2 managed rules and rate limiting. It is disabled by default through `enable_waf = false`.

CloudFront uses `viewer_protocol_policy = "redirect-to-https"`. A custom domain requires a valid ACM certificate in `us-east-1`.

## Database Protection

Current demo settings:

- RDS MySQL 8.0
- Not publicly accessible
- Backup retention defaults to 7 days
- Deletion protection disabled
- Final snapshot skipped

Recommended improvement: enable deletion protection and final snapshots for production-like environments.

## CORS

Terraform sets `cors_origin` to the custom domain when configured, otherwise it falls back to `*`.

Recommended improvement: avoid wildcard CORS in real deployments and explicitly set allowed frontend domains.
