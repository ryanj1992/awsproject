#---------------------------------------------- ECS

resource "aws_ecs_cluster" "ecs_cluster" {
    name = var.application_name
}

resource "aws_lb_target_group" "alb_target_group" {
  port     = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = aws_vpc.main.id
}

resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.public_alb.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.alb_target_group.id
    type = "forward"
  }

}

resource "aws_ecs_service" "ecs_service" {
    name = "hello_world_service"
    cluster = aws_ecs_cluster.ecs_cluster.arn
    launch_type = var.launch_type

    deployment_maximum_percent = 200
    deployment_minimum_healthy_percent = 100
    desired_count = 1
    task_definition = aws_ecs_task_definition.hello_world_td.family

    load_balancer {
        target_group_arn = aws_lb_target_group.alb_target_group.arn
        container_name = var.container_name # Set as variable
        container_port = var.port_mappings[containerPort] # Add count if more than one
    }

    network_configuration {
      security_groups = [aws_security_group.private_security_group.id]
      subnets = aws_subnet.private_subnet.*.id
      assign_public_ip = true
    }
}

# Default task definition module
module "ecs_hello_world" {
    source = "git::https://github.com/cloudposse/terraform-aws-ecs-container-definition.git?ref=tags/0.49.0"
    container_name = var.container_name
    container_image = var.container_image
    port_mappings = var.port_mappings
}

resource "aws_ecs_task_definition" "hello_world_td" {
    container_definitions = module.ecs_hello_world.json_map_encoded_list
    family = var.application_name
    requires_compatibilities = [var.launch_type]

    cpu = var.cpu
    memory = var.memory
    network_mode = var.network_mode
}


