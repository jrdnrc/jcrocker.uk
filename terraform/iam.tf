resource "aws_iam_openid_connect_provider" "github" {
  url            = local.oidc_provider_url
  client_id_list = ["sts.amazonaws.com"]
  tags = {
    ManagedBy = "terraform"
    Service   = "github-actions"
  }
}

# IAM role that can be assumed via web identity from GitHub Actions
resource "aws_iam_role" "github_actions_role" {
  name = "jcrocker.uk-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          },
          StringLike = {
            "token.actions.githubusercontent.com:sub" = length(local.repo_subjects) == 1 ? local.repo_subjects[0] : local.repo_subjects
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_policy_attachment" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.website_read_write_policy.arn
}

resource "aws_iam_user_policy_attachment" "jordan_policy_attachment" {
  user       = data.aws_iam_user.jordan.user_name
  policy_arn = aws_iam_policy.website_read_write_policy.arn
}

resource "aws_iam_user_policy_attachment" "jordan_admin_policy_attachment" {
  user       = data.aws_iam_user.jordan.user_name
  policy_arn = data.aws_iam_policy.admin_policy.arn
}

resource "aws_iam_policy" "website_read_write_policy" {
  name        = "jcrocker.uk-website-read-write-policy"
  description = "Permissions to read and write to the website buckets"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:DeleteObject",
        ],
        Resource = [
          aws_s3_bucket.jcrocker-uk-files.arn,
          "${aws_s3_bucket.jcrocker-uk-files.arn}/*",
          aws_s3_bucket.www-jcrocker-uk-files.arn,
          "${aws_s3_bucket.www-jcrocker-uk-files.arn}/*"
        ]
      }
    ]
  })
}

data "aws_iam_user" "jordan" {
  user_name = "jordan"
}

data "aws_iam_policy" "admin_policy" {
  name = "AdministratorAccess"
}