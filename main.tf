data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${var.environment}-vpc" 
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-gw" 
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  
  tags = {
    Name = "${var.environment}-private-rt"
  }
}

resource "aws_subnet" "private_subnet" {
  count = 2
  vpc_id = aws_vpc.main.id
  cidr_block = var.private_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.environment}-private-subnet-${count.index + 1}"
  }
}

resource "aws_route_table_association" "private_assoc" {
  count = length(aws_subnet.private_subnet)
  subnet_id = aws_subnet.private_subnet.*.id[count.index]
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_security_group" "private_security_group" {
  vpc_id = aws_vpc.main.id

  ingress {
    protocol   = "tcp"
    cidr_blocks = [var.access_ip]
    from_port  = 80
    to_port    = 80
  }

  # DOES NAT GATEWAY HANDLE THIS????
  # egress {
  #   from_port = 0
  #   to_port = 0
  #   protocol = "-1" # all protocols
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  tags = {
    Name = "${var.environment}-private-sg"
  }
}

resource "aws_lb" "public_alb" {
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.private_security_group.id]
  subnets = aws_subnet.private_subnet.*.id

  # access_logs {
  #   bucket  = aws_s3_bucket.lb_logs.bucket
  #   prefix  = "${var.environment}-public-alb"
  #   enabled = true
  # }

  tags = {
    Name = "${var.environment}-public-alb"
  }
}

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
        container_name = "hello_world" # Set as variable
        container_port = 80
    }

    network_configuration {
      security_groups = [aws_security_group.private_security_group.id]
      subnets = aws_subnet.private_subnet.*.id
      assign_public_ip = true
    }
}

module "ecs_hello_world" {
    source = "git::https://github.com/cloudposse/terraform-aws-ecs-container-definition.git?ref=tags/0.49.0"
    container_name = "hello_world"
    container_image = "nginxdemos/hello"
    port_mappings = [
      {
        containerPort = 80
        hostPort      = 80
        protocol      = "tcp"
      }
    ]
}

resource "aws_ecs_task_definition" "hello_world_td" {
    container_definitions = module.ecs_hello_world.json_map_encoded_list # ????
    family = var.application_name
    requires_compatibilities = [var.launch_type]

    cpu = "256"
    memory = "512"
    network_mode = "awsvpc"
}

# All works but need to include nat gateway to be able to download image
# without public ip