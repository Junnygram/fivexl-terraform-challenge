provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket         = "fivexl-terraform-state-dev" # Sharing dev bucket for demo
    key            = "s3-demo/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "fivexl-terraform-locks"
    encrypt        = true
  }
}

module "static_site" {
  source = "../../modules/s3-site"

  bucket_name_prefix = "fivexl-demo-site"
  environment        = "example"
}

output "cdn_domain" {
  value = module.static_site.cloudfront_domain_name
}
