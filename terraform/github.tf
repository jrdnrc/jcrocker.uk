provider "github" {
  token = var.gh_token
  owner = "jrdnrc"
}

resource "github_repository" "jcrocker-uk" {
  name        = "jcrocker.uk"
  description = "https://jcrocker.uk"
  visibility  = "public"

  has_downloads = true
  has_issues    = true
  has_projects  = true
  has_wiki      = true
}

resource "github_repository_environment" "production" {
  repository  = github_repository.jcrocker-uk.name
  environment = "production"
}

resource "github_actions_environment_secret" "deploy_role" {
  repository      = github_repository.jcrocker-uk.name
  environment     = github_repository_environment.production.environment
  secret_name     = "AWS_DEPLOY_ROLE"
  plaintext_value = aws_iam_role.github_actions_role.arn
}

resource "github_actions_environment_secret" "aws_region" {
  repository      = github_repository.jcrocker-uk.name
  environment     = github_repository_environment.production.environment
  secret_name     = "AWS_REGION"
  plaintext_value = var.aws_region
}

resource "github_actions_environment_secret" "bucket_name" {
  for_each = {
    "BUCKET"     = aws_s3_bucket.jcrocker-uk-files.id,
    "BUCKET_WWW" = aws_s3_bucket.www-jcrocker-uk-files.id
  }

  repository      = github_repository.jcrocker-uk.name
  environment     = github_repository_environment.production.environment
  secret_name     = each.key
  plaintext_value = each.value
}
