provider "aws" {
  region = "us-east-1"
}

module "static_site" {
  source = "../../modules/s3-site"

  bucket_name_prefix = "fivexl-demo-site"
  environment        = "example"
}

output "cdn_domain" {
  value = module.static_site.cloudfront_domain_name
}
