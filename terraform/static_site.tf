resource "aws_s3_bucket" "ui_bucket" {
  bucket = "twss-ui-${var.environment}"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "ui_bucket_policy" {
  bucket = aws_s3_bucket.ui_bucket.id
  policy = data.aws_iam_policy_document.ui_bucket_policy.json
}

data "aws_iam_policy_document" "ui_bucket_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.ui_bucket.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_cloudfront_distribution" "ui_cdn" {
  origin {
    domain_name = aws_s3_bucket.ui_bucket.bucket_regional_domain_name
    origin_id   = "uiS3Origin"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "uiS3Origin"
    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
