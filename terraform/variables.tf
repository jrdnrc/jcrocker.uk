# Build default subject if none provided
locals {
  repo_subjects = "repo:jrdnrc/jcrocker.uk:*"

  oidc_provider_url = "https://token.actions.githubusercontent.com"
  oidc_provider_arn = "arn:aws:iam::${var.aws_account_id}:oidc-provider/token.actions.githubusercontent.com"
}

variable "aws_access_key" {
  type      = string
}

variable "aws_secret_key" {
  type      = string
  sensitive = true
}

variable "aws_account_id" {
  type      = string
}

variable "aws_region" {
  type      = string
  default   = "eu-west-1"
}

variable "cf_token" {
  type      = string
  sensitive = true
}

variable "cf_zone_id" {
  type      = string
}

variable "gh_token" {
  description = "GitHub API token"
  type        = string
  sensitive   = true
}