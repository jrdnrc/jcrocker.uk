terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.20.0"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.12.0"
    }

    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket = "jrdn-tf-state"
    key = "jcrocker.uk/terraform.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  region = "eu-west-1"

  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

provider "cloudflare" {
  api_token = var.cf_token
}

resource "cloudflare_dns_record" "records" {
  for_each = {
    "jcrocker.uk"     = aws_s3_bucket_website_configuration.jcrocker-uk-files["jcrocker.uk"].website_endpoint,
    "www.jcrocker.uk" = aws_s3_bucket_website_configuration.jcrocker-uk-files["www.jcrocker.uk"].website_endpoint
  }

  zone_id = var.cf_zone_id
  name    = each.key
  type    = "CNAME"
  content = each.value
  proxied = true
  ttl     = 1
}

moved {
  from = aws_s3_bucket_website_configuration.jcrocker-uk-files
  to   = aws_s3_bucket_website_configuration.jcrocker-uk-files["jcrocker.uk"]
}

moved {
  from = aws_s3_bucket_website_configuration.www-jcrocker-uk-files
  to   = aws_s3_bucket_website_configuration.jcrocker-uk-files["www.jcrocker.uk"]
}
