locals {
     alb_account = var.environment == "us-east-1" ? "127311923021" : "156460612806"
}

resource "aws_s3_bucket" "alb_logs" {
  bucket        = "nginx-hello-world-alb-logs-${var.environment}"
  force_destroy = true
  tags = {
    Name = "${var.environment}-nginx-hello-world-alb-logs"
  }
}

resource "aws_s3_bucket_policy" "access_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${local.alb_account}:root"
        },
        "Action" : "s3:PutObject",
        "Resource" : "arn:aws:s3:::nginx-hello-world-alb-logs-${var.environment}/*"
      },
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "delivery.logs.amazonaws.com"
        },
        "Action" : "s3:PutObject",
        "Resource" : "arn:aws:s3:::nginx-hello-world-alb-logs-${var.environment}/*",
        "Condition" : {
          "StringEquals" : {
            "s3:x-amz-acl" : "bucket-owner-full-control"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "delivery.logs.amazonaws.com"
        },
        "Action" : "s3:GetBucketAcl",
        "Resource" : "arn:aws:s3:::nginx-hello-world-alb-logs-${var.environment}"
      }
    ]
  })
}