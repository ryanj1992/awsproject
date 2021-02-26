# Environment vars
aws_region = "us-east-1"

# ECS vars
launch_type      = "FARGATE"
application_name = "nginx_hello_world"
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

# Auto Scaling vars

min_capacity       = 2
max_capacity       = 4
target_value       = 70
scale_in_cooldown  = 120
scale_out_cooldown = 120

# Networking vars

access_ip = "0.0.0.0/0"
nacl_ingress = [
    {
        rule_no    = 100
        action     = "allow"
        from_port  = 80
        to_port    = 80
    },

    {
        rule_no    = 120
        action     = "allow"
        from_port  = 443
        to_port    = 443
    },

    {
        rule_no    = 110
        action     = "allow"
        from_port  = 1024
        to_port    = 65535
    }]

nacl_egress = [
    {
        rule_no    = 100
        action     = "allow"
        from_port  = 80
        to_port    = 80
    },

    {
        rule_no    = 120
        action     = "allow"
        from_port  = 443
        to_port    = 443
    },

    {
        rule_no    = 110
        action     = "allow"
        from_port  = 1024
        to_port    = 65535
    }]

sg_ingress = [
    {
        from_port   = 80
        to_port     = 80
    },

    { 
      from_port   = 443
      to_port     = 443
    }
]