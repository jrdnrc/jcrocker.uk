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
    key    = "jcrocker.uk/terraform.tfstate"
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

resource "cloudflare_dns_record" "jcrocker_uk" {
  zone_id = var.cf_zone_id
  name    = "jcrocker.uk"
  type    = "CNAME"
  content = aws_s3_bucket_website_configuration.jcrocker-uk-files["jcrocker.uk"].website_endpoint
  proxied = true
  ttl     = 1
}

resource "cloudflare_dns_record" "www_jcrocker_uk" {
  zone_id = var.cf_zone_id
  name    = "www.jcrocker.uk"
  type    = "CNAME"
  content = cloudflare_dns_record.jcrocker_uk.name
  proxied = true
  ttl     = 1
}

resource "cloudflare_ruleset" "redirect_www_to_root" {
  zone_id = var.cf_zone_id
  name    = "Redirect www.jcrocker.uk to jcrocker.uk"
  kind    = "zone"
  phase   = "http_request_dynamic_redirect"

  rules = [{
    enabled     = true
    description = "Redirect all www.jcrocker.uk requests to jcrocker.uk"
    action      = "redirect"

    expression = "(http.host eq \"www.jcrocker.uk\")"

    action_parameters = {
      from_value = {
        status_code = 301
        target_url = {
          expression = "concat(\"https://jcrocker.uk\", http.request.uri.path)"
        }
        preserve_query_string = true
      }
    }
  }]
}