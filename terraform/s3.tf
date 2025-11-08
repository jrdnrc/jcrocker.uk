resource "aws_s3_bucket" "jcrocker-uk-files" {
  bucket = "jcrocker.uk"
}

resource "aws_s3_bucket" "www-jcrocker-uk-files" {
  bucket = "www.jcrocker.uk"
}


resource "aws_s3_bucket_website_configuration" "jcrocker-uk-files" {
  for_each = {
    "jcrocker.uk"     = aws_s3_bucket.jcrocker-uk-files.id
    "www.jcrocker.uk" = aws_s3_bucket.www-jcrocker-uk-files.id
  }
  bucket = each.value

  expected_bucket_owner = var.aws_account_id

  index_document {
    suffix = "index.htm"
  }

  error_document {
    key = "index.htm"
  }
}