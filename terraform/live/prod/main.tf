provider "aws" {
  region = "us-east-1"
  # In a real multi-account setup, you might use a profile or assume_role here
  # profile = "prod-account"
}

terraform {
  backend "s3" {
    bucket         = "fivexl-terraform-state-prod" # Placeholder
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "fivexl-terraform-locks"
    encrypt        = true
  }
}

module "website" {
  source = "../../modules/ec2-site"

  environment   = "prod"
  vpc_cidr      = "10.1.0.0/16" # Different CIDR for Prod
  instance_type = "t3.small"    # Larger instance for Prod
  ssh_key_name  = "prod-key"
  
  html_content = replace(file("${path.module}/../../../src/index.html"), "{{ENV}}", "PROD")
}

output "website_url" {
  value = module.website.alb_dns_name
}
