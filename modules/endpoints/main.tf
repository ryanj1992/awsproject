resource "aws_vpc_endpoint" "ecs_api" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.us-east-1.ecr.api"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    var.security_group,
  ]

  subnet_ids = var.private_subnet_id

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ecs_dkr" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.us-east-1.ecr.dkr"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    var.security_group,
  ]

  subnet_ids = var.private_subnet_id

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.us-east-1.s3"
}