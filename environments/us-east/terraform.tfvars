# Environment vars
environment = "us-east"
aws_region  = "us-east-1"

# ECS vars
launch_type      = "FARGATE"
application_name = "nginx_hello_world"
container_image  = "nginxdemos/hello"
container_name   = "nginx_hello_world"
port_mappings = [
  {
    containerPort = 80
    hostPort      = 80
    protocol      = "tcp"
  }
]
cpu          = "256"
memory       = "512"
network_mode = "awsvpc"

# Networking vars
cidr_block = "10.0.0.0/16"
private_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]
public_cidrs = [
  "10.0.3.0/24",
  "10.0.4.0/24"
]
access_ip = "0.0.0.0/0"