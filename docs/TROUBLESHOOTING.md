# Troubleshooting

## Frontend Cannot Reach Backend

- Check CloudFront and ALB DNS outputs.
- Confirm the app repository `docker-compose.prod.yml` exposes the expected frontend/backend ports.
- Confirm the ALB target group has healthy targets.
- Review EC2 bootstrap logs:

```bash
sudo tail -n 200 /var/log/user-data.log
```

## Database Connection Failed

- Confirm RDS is available in the AWS Console.
- Confirm the EC2 security group is allowed to reach the RDS security group on port 3306.
- Confirm SSM parameters exist:

```bash
aws ssm get-parameter --name "/hospital/prod/db_username"
aws ssm get-parameter --name "/hospital/prod/db_password" --with-decryption
```

- On EC2, verify the generated backend `.env` file exists and has the expected database host, port, name, and user.

## CORS Error

- Check `custom_domain` in `environments/prod/terraform.tfvars`.
- If no custom domain is set, Terraform falls back to `*`.
- For real deployments, set a specific frontend domain and redeploy the EC2 instance or update backend environment variables.

## Missing Environment Variables

- Verify all required SSM parameters exist under `/hospital/prod/`.
- Check IAM permissions for the EC2 instance profile.
- Review `/var/log/user-data.log` for failed `aws ssm get-parameter` commands.

## Docker Container Fails

On EC2:

```bash
cd /opt/webhospital-booking
docker-compose -f docker-compose.prod.yml ps
docker-compose -f docker-compose.prod.yml logs --tail=200
```

Common causes:

- Missing `docker-compose.prod.yml` in the app repository
- Missing `backend/.env`
- Backend cannot connect to RDS
- Database schema file path differs from `database/schema.sql`

## EC2 user_data Not Running

- Check `/var/log/user-data.log`.
- Confirm the Launch Template contains the expected rendered user data.
- Confirm the instance can reach GitHub, SSM, and package repositories.
- Confirm the instance profile is attached.

## ALB Health Check Failed

- The target group expects `GET /health` to return HTTP 200.
- Confirm the backend or frontend proxy exposes `/health` on `app_port`.
- Confirm the EC2 security group allows traffic from the ALB security group.
- Confirm Docker containers are running and listening on the expected port.

## Terraform Backend Init Fails

- Confirm the S3 bucket in `environments/prod/backend.tf` exists.
- Confirm AWS credentials are configured.
- Confirm the AWS region matches the backend configuration.
- If using S3 native lockfile support, ensure the installed provider/backend version supports the configured backend arguments.
