resource "aws_s3_bucket" "ui_bucket" {
  bucket = "twss-ui-${var.environment}"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "allow_cloudfront" {
  bucket = aws_s3_bucket.ui_bucket.id
  policy = data.aws_iam_policy_document.cloudfront.json
}

data "aws_iam_policy_document" "cloudfront" {
  statement {
    sid     = "AllowCloudFrontServicePrincipalReadOnlyAccess"
    effect  = "Allow"
    actions = ["s3:GetObject"]

    resources = [
      aws_s3_bucket.ui_bucket.arn,
      "${aws_s3_bucket.ui_bucket.arn}/*",
    ]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values = [
        aws_cloudfront_distribution.ui_cdn.arn
      ]
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
