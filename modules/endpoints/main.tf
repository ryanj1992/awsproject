# IAM role for ECS to pull from ECR

# Endpoints for ECS to pull from ECR

resource "aws_vpc_endpoint" "ecs_api" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.environment}.ecr.api" # needs replacing with var.environment
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    var.security_group,
  ]

  subnet_ids          = var.private_subnet_id
  private_dns_enabled = true

  tags = {
    Name = "${var.environment}_ecs_api_endpoint"
  }
}

resource "aws_vpc_endpoint" "ecs_dkr" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.environment}.ecr.dkr" # needs replacing with var.environment
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    var.security_group,
  ]

  subnet_ids          = var.private_subnet_id
  private_dns_enabled = true

  tags = {
    Name = "${var.environment}_ecs_dkr_endpoint"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${var.environment}.s3" # needs replacing with var.environment

  tags = {
    Name = "${var.environment}_s3_endpoint"
  }
}