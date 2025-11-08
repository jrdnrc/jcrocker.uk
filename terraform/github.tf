provider "github" {
  token = var.gh_token
  owner = "jrdnrc"
}

resource "github_repository" "jcrocker-uk" {
  name        = "jcrocker.uk"
  description = "https://jcrocker.uk"
  visibility  = "public"

  has_downloads = false
  has_issues    = false
  has_projects  = false
  has_wiki      = false
}

resource "github_repository_environment" "production" {
  repository  = github_repository.jcrocker-uk.name
  environment = "production"
}

resource "github_repository_environment" "staging" {
  repository  = github_repository.jcrocker-uk.name
  environment = "staging"
}

resource "github_actions_environment_secret" "deploy_role" {
  for_each = toset([
    github_repository_environment.production.environment,
    github_repository_environment.staging.environment
  ])
  repository      = github_repository.jcrocker-uk.name
  environment     = each.value
  secret_name     = "AWS_DEPLOY_ROLE"
  plaintext_value = aws_iam_role.github_actions_role.arn
}

resource "github_actions_environment_secret" "aws_region" {
  for_each = toset([
    github_repository_environment.production.environment,
    github_repository_environment.staging.environment
  ])
  repository      = github_repository.jcrocker-uk.name
  environment     = each.value
  secret_name     = "AWS_REGION"
  plaintext_value = var.aws_region
}

resource "github_actions_environment_secret" "production_deploy_path" {
  for_each = {
    "DEPLOY_PATH"     = "s3://${aws_s3_bucket.jcrocker-uk-files.id}",
    "DEPLOY_PATH_WWW" = "s3://${aws_s3_bucket.www-jcrocker-uk-files.id}"
  }

  repository      = github_repository.jcrocker-uk.name
  environment     = github_repository_environment.production.environment
  secret_name     = each.key
  plaintext_value = each.value
}

resource "github_actions_environment_secret" "staging_deploy_path" {
  for_each = {
    "DEPLOY_PATH"     = "s3://${aws_s3_bucket.jcrocker-uk-files.id}/staging",
    "DEPLOY_PATH_WWW" = "s3://${aws_s3_bucket.www-jcrocker-uk-files.id}/staging"
  }

  repository      = github_repository.jcrocker-uk.name
  environment     = github_repository_environment.staging.environment
  secret_name     = each.key
  plaintext_value = each.value
}