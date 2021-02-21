# Environment vars
# environment = "us-east" # not used
aws_region  = "us-east-1"

# ECS vars
launch_type      = "FARGATE"
application_name = "nginx_hello_world"
container_image  = "nginxdemos/hello" # 763762324283.dkr.ecr.us-east-1.amazonaws.com/nginx_hello_world
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
# cidr_block = "10.0.0.0/16" # not used
# private_cidrs = [ # not used
#   "10.0.1.0/24",
#   "10.0.2.0/24"
# ]
# public_cidrs = [ # not used
#   "10.0.3.0/24",
#   "10.0.4.0/24"
# ]
access_ip = "0.0.0.0/0"


# Auto Scaling vars

min_capacity = 2
max_capacity = 4
target_value = 70
scale_in_cooldown = 120
scale_out_cooldown = 120


# S3 vars

# bucket_name = "nginx_alb_ingress_logs_" # not used