#---------------------------------------------- ECS

locals {
  application_name = var.environment == "us-east-1" ? "nginx-hello-world-us" : "nginx-hello-world-eu"
}

data "aws_ecr_repository" "service" {
  name = "nginx_hello_world"
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = local.application_name

  tags = {
    Name = "${var.environment}_ecs_cluster"
  }
}

resource "aws_lb_target_group" "alb_target_group" {
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.main_vpc

  tags = {
    Name = "${var.environment}_lb_tg"
  }
}


resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = var.public_alb
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.alb_target_group.id
    type             = "forward"
  }

}

resource "aws_ecs_service" "ecs_service" {
  name        = local.application_name
  cluster     = aws_ecs_cluster.ecs_cluster.arn
  launch_type = var.launch_type

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  desired_count                      = 2
  task_definition                    = aws_ecs_task_definition.hello_world_td.family
  platform_version                   = "1.4.0"

  lifecycle {
    ignore_changes = [
    desired_count]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.alb_target_group.arn
    container_name   = var.container_name
    container_port   = 80
  }

  network_configuration {
    security_groups  = [var.security_group]
    subnets          = var.private_subnet
    assign_public_ip = false
  }

  tags = {
    Name = "${var.environment}_${var.container_name}_ecs_service"
  }
}

# Default task definition module
module "ecs_hello_world" {
  source          = "git::https://github.com/cloudposse/terraform-aws-ecs-container-definition.git?ref=tags/0.49.0"
  container_name  = var.container_name
  container_image = data.aws_ecr_repository.service.repository_url
  port_mappings   = var.port_mappings
}

resource "aws_ecs_task_definition" "hello_world_td" {
  container_definitions    = module.ecs_hello_world.json_map_encoded_list
  family                   = local.application_name
  requires_compatibilities = [var.launch_type]

  cpu          = var.cpu
  memory       = var.memory
  network_mode = var.network_mode
  execution_role_arn = var.execution_role_arn
  task_role_arn = var.execution_role_arn

  volume {
    name = "nginx-hello-world-efs"

    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.ecs_efs.id
      root_directory          = "/opt/data"
      # transit_encryption      = "ENABLED"
      # transit_encryption_port = 2999
    }
  }

  tags = {
    Name = "${var.environment}_${var.container_name}_ecs_task_definition"
  }
}

# EFS file system

resource "aws_efs_file_system" "ecs_efs" {
  creation_token = "${var.environment}_nginx_hello_world"

  tags = {
    Name = "${var.environment}_efs_nginx_hello_world"
  }
}

resource "aws_efs_mount_target" "alpha" {
  file_system_id = aws_efs_file_system.ecs_efs.id
  subnet_id      = var.private_subnet[0]
}
