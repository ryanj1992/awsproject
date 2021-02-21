#---------------------------------------------- ECS

locals {
  application_name = var.environment == "us-east-1" ? "nginx_hello_world_us" : "nginx_hello_world_eu"
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
  vpc_id      = var.main_vpc #aws_vpc.main.id

  tags = {
    Name = "${var.environment}_lb_tg"
  }
}

resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = var.public_alb # aws_lb.public_alb.arn
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
  task_definition                    = aws_ecs_task_definition.hello_world_td.family # REVISION here

  lifecycle {
    ignore_changes = [
    desired_count]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.alb_target_group.arn
    container_name   = var.container_name # Set as variable
    container_port   = 80
  }

  network_configuration {
    security_groups  = [var.security_group] # aws_security_group.private_security_group.id
    subnets          = var.private_subnet   # aws_subnet.private_subnet.*.id
    assign_public_ip = false
  }
}

# Default task definition module
module "ecs_hello_world" {
  source          = "git::https://github.com/cloudposse/terraform-aws-ecs-container-definition.git?ref=tags/0.49.0"
  container_name  = var.container_name
  container_image = var.container_image
  port_mappings   = var.port_mappings
}

resource "aws_ecs_task_definition" "hello_world_td" {
  container_definitions    = module.ecs_hello_world.json_map_encoded_list
  family                   = local.application_name
  requires_compatibilities = [var.launch_type]

  cpu          = var.cpu
  memory       = var.memory
  network_mode = var.network_mode
  # execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
}


