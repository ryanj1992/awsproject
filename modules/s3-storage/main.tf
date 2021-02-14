resource "aws_s3_bucket" "alb_logs" {
  bucket = "nginx-hello-world-alb-logs-${var.environment}"
  acl    = "public-read-write"
  force_destroy = true
  tags = {
    Name        = "${var.environment}-nginx-hello-world-alb-logs"
  }
}