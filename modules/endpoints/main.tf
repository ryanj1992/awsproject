# IAM role for ECS to pull from ECR

data "aws_iam_policy_document" "ecs_tasks_execution_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_tasks_execution_role" {
  name               = "ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_execution_role.json

  tags = {
    Name = "${var.environment}_ecs_tasks_execution_role"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_tasks_execution_role" {
  role       = aws_iam_role.ecs_tasks_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


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