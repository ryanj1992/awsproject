output "alb_logs_bucket" {
  value = data.aws_s3_bucket.alb_logs.bucket
}