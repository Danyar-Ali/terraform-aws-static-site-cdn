## Terraform AWS Static Site – Secure IaC Deployment

Production-style Infrastructure as Code project deploying a private S3 static site behind CloudFront using Terraform and GitHub Actions with OIDC (no long-lived AWS credentials).

```
GitHub Actions (OIDC)
        │
        ▼
Terraform Apply
        │
        ├── S3 Bucket (private)
        │       ├── Versioning enabled
        │       ├── Public access blocked
        │       └── Bucket policy (CloudFront only)
        │
        └── CloudFront Distribution
                ├── Origin Access Control (OAC)
                ├── HTTPS only
                └── Cache invalidation on deploy
```

## Security Highlights

* No AWS access keys stored in GitHub
* OIDC federation between GitHub Actions and AWS
* IAM least-privilege policy scoped to cv-static-site-*
* S3 bucket fully private (no public access)
* CloudFront OAC restricts direct S3 access
* HTTPS enforced

## Tech Stack

* Terraform ≥ 1.6
* AWS Provider ≥ 5.0
* GitHub Actions
* AWS S3
* AWS CloudFront
* AWS IAM (OIDC federation)

## Project Structure

```
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── site/
│   └── index.html
└── .github/workflows/deploy.yml
```

## CI/CD Workflow

On every push to main:

* GitHub Actions authenticates to AWS using OIDC
* Terraform initializes and applies infrastructure
* Static site is uploaded to S3
* CloudFront cache is invalidated
* Deployment completes automatically
* No manual AWS console interaction required.

## After successful pipeline run:

```https://<cloudfront-domain>```

# Terraform outputs:

* s3_bucket_name
* cloudfront_domain_name
* site_url

## Key Implementation Details
Origin Access Control (OAC)

Prevents public access to S3. Only CloudFront can fetch objects.

```
* origin_access_control_origin_type = "s3"
* signing_behavior                  = "always"
* signing_protocol                  = "sigv4"
```

## IAM Least Privilege

The GitHub role is restricted to:

* S3 actions scoped to arn:aws:s3:::cv-static-site-*
* Required CloudFront management actions
* OIDC trust locked to:

```
repo:Danyar-Ali/<repo-name>:ref:refs/heads/main
```

## GitHub OIDC Configuration
```
permissions:
  id-token: write
  contents: read

- uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
    aws-region: eu-north-1
```

## Noteworthy Questions

# Why OIDC Instead of Access Keys?

Traditional CI/CD:

* Stores long-lived AWS keys in secrets
* Higher risk of credential leakage

# This implementation:

* Uses short-lived federated tokens
* Eliminates static AWS credentials
* Follows AWS security best practices

  ## How to Deploy

1. Configure IAM OIDC provider in AWS

2. Create IAM role with least privilege policy

3. Add role ARN to GitHub as AWS_ROLE_ARN

4. Push to main

Deployment runs automatically.

## Working link after deployment: 

```d2tpt8udf6jnro.cloudfront.net```

## Author

Danyar Ali
Cloud & DevOps Engineer
