# Setup Instructions

## Prerequisites
1. **AWS CLI** installed and configured (`aws configure`).
2. **Terraform** installed (v1.0+).
3. **GitHub Account** (for the repo and actions).

## 1. Bootstrap Remote State (One-time setup)
Before running Terraform code that requires a backend, you must create the S3 bucket and DynamoDB table. You can do this manually in the AWS Console or using the AWS CLI.

**Run these commands to create them (adjust region/names if needed):**

```bash
# Variables
# IMPORTANT: These must match what is in terraform/live/*/main.tf
REGION="us-east-1"
BUCKET_DEV="fivexl-terraform-state-dev"
BUCKET_PROD="fivexl-terraform-state-prod"
TABLE="fivexl-terraform-locks"

# If using a specific profile, add --profile your-profile-name to the commands below
# Example: aws s3api create-bucket --bucket $BUCKET_DEV --region $REGION --profile personal

# Create S3 Buckets
aws s3api create-bucket --bucket $BUCKET_DEV --region $REGION
aws s3api create-bucket --bucket $BUCKET_PROD --region $REGION

# Enable Versioning
aws s3api put-bucket-versioning --bucket $BUCKET_DEV --versioning-configuration Status=Enabled
aws s3api put-bucket-versioning --bucket $BUCKET_PROD --versioning-configuration Status=Enabled

# Create DynamoDB Table for Locking
aws dynamodb create-table \
    --table-name $TABLE \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --region $REGION
```

## 2. Generate SSH Keys (For EC2 Access)
The EC2 instances need SSH keys.

```bash
# Dev Key
aws ec2 create-key-pair --key-name dev-key --query 'KeyMaterial' --output text > dev-key.pem
chmod 400 dev-key.pem

# Prod Key
aws ec2 create-key-pair --key-name prod-key --query 'KeyMaterial' --output text > prod-key.pem
chmod 400 prod-key.pem
```

## 3. Configure GitHub Actions OIDC (Recommended)
Instead of static Access Keys, we will use OIDC for security.

1.  **Deploy the OIDC Infrastructure:**
    You need to tell AWS to trust your GitHub repository.
    ```bash
    cd terraform/live/global/oidc
    terraform init
    # Configure your AWS credentials manually for this step
    export AWS_PROFILE=your-profile
    # Replace with your actual username/repo
    export TF_VAR_github_repo="your-username/fivexl-challenge"
    terraform apply
    ```

2.  **Add Secret to GitHub:**
    *   Take the `role_arn` output from the previous step.
    *   Go to your GitHub Repo -> Settings -> Secrets and variables -> Actions.
    *   Add a New Repository Secret:
        *   Name: `AWS_ROLE_ARN`
        *   Value: `arn:aws:iam::123456789012:role/GitHubActions-Terraform-Role` (The output from `terraform apply`)

## 4. Deployment
The pipeline is now configured to use OIDC. Simply push to `main` to deploy.

**Local Deployment:**
You can still deploy locally using your AWS profile:

```bash
cd terraform/live/dev
export AWS_PROFILE=your-dev-profile
terraform init
terraform apply
```
