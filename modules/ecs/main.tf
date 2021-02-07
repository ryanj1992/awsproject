resource "aws_ecs_cluster" "ecs_cluster" {
    name = var.application_name
}

resource "aws_lb_target_group" "alb_target-group" {
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_ecs_service" "ecs_service" {
    name = "hello_world_service"
    cluster = aws_ecs_cluster.ecs_cluster.arn
    launch_type = var.launch_type

    deployment_maximum_percent = 200
    deployment_minimum_percent = 100
    desired_count = 1

    load_balancer {
        target_group_arn = aws_lb_target_group.alb_target_group.arm
        container_name = "hello_world" # Set as variable
        container_port = 80
    }
}

module "ecs_hello_world" {
    source = "git::https://github.com/cloudposse/terraform-aws-ecs-container-definition.git?ref=tags/0.49.0"
    container_name "hello_world"
    container_image "nginxdemos/hello"
}

resource "aws_ecs_task_definition" {
    container_definitions = [module.ecs_hello_world.json]
    family = [var.application_name]
    requires_compatibilities = [var.launch_type]

    cpu = "256"
    memory = "512"
    network_node = "awsvpc"
}


