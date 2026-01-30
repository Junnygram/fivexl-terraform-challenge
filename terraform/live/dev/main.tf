# Deploying infrastructure for dev environment
provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket         = "fivexl-terraform-state-dev" # Placeholder
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "fivexl-terraform-locks"
    encrypt        = true
  }
}

module "website" {
  source = "../../modules/ec2-site"

  environment   = "dev"
  vpc_cidr      = "10.0.0.0/16"
  instance_type = "t3.micro"
  ssh_key_name  = "dev-key-v2"
  
  html_content = replace(file("${path.module}/../../../src/index.html"), "{{ENV}}", "DEV")
}

output "website_url" {
  value = module.website.alb_dns_name
}
