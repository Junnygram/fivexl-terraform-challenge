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
REGION="us-east-1"
BUCKET_DEV="fivexl-terraform-state-dev"
BUCKET_PROD="fivexl-terraform-state-prod"
TABLE="fivexl-terraform-locks"

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

## 3. Deployment
You can deploy via GitHub Actions (configured in `.github/workflows/deploy.yml`) or locally.

**Local Deployment:**

```bash
cd terraform/live/dev
export AWS_PROFILE=your-dev-profile  # If using profiles
terraform init
terraform apply
```

## 4. GitHub Actions Setup
To use the CI/CD pipeline:
1. Create a new repository on GitHub.
2. Push this code to it.
3. Add the following **Secrets** to your GitHub Repo settings:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

The pipeline will automatically plan and apply changes to Dev and Prod on push to `main`.
