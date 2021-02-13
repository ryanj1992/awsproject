module "us-east-1" {
    source = "../../modules/networking"
    environment   = "us-east-1"
    cidr_block    = "10.0.0.0/16"
    private_cidrs = [
      "10.0.1.0/24",
      "10.0.2.0/24"
    ]
    public_cidrs = [
      "10.0.3.0/24",
      "10.0.4.0/24"
    ]
    access_ip     = var.access_ip
    providers = {
        aws = aws.us-east-1
    }
}

module "eu-west-1" {
    source = "../../modules/networking"
    environment   = "eu-west-1"
    cidr_block    = "10.1.0.0/16"
    private_cidrs = [
      "10.1.1.0/24",
      "10.1.2.0/24"
    ]
    public_cidrs = [
      "10.1.3.0/24",
      "10.1.4.0/24"
    ]
    access_ip     = var.access_ip
    providers = {
        aws = aws.us-east-1
    }
}

module "ecs-us" {
  source           = "../../modules/ecs"
  environment      = "us-east-1"
  application_name = "nginx_hello_world_us"
  launch_type      = var.launch_type
  container_image  = var.container_image
  container_name   = var.container_name
  port_mappings    = var.port_mappings
  cpu              = var.cpu
  memory           = var.memory
  network_mode     = var.network_mode
  public_alb       = module.us-east-1.public_lb_arn
  main_vpc         = module.us-east-1.main_vpc_id
  security_group   = module.us-east-1.private_sg_id
  private_subnet   = module.us-east-1.private_subnet_id
}

module "ecs-eu" {
  source           = "../../modules/ecs"
  environment   = "eu-west-1"
  application_name = "nginx_hello_world_eu"
  launch_type      = var.launch_type
  container_image  = var.container_image
  container_name   = var.container_name
  port_mappings    = var.port_mappings
  cpu              = var.cpu
  memory           = var.memory
  network_mode     = var.network_mode
  public_alb       = module.eu-west-1.public_lb_arn
  main_vpc         = module.eu-west-1.main_vpc_id
  security_group   = module.eu-west-1.private_sg_id
  private_subnet   = module.eu-west-1.private_subnet_id
}

module "autoscaling-us" {
  source      = "../../modules/autoscaling"
  ecs_cluster = "nginx_hello_world_us"
  ecs_service = "nginx_hello_world_us"
  min_capacity = var.min_capacity
  max_capacity = var.max_capacity
  target_value = var.target_value
  scale_in_cooldown = var.scale_in_cooldown
  scale_out_cooldown = var.scale_out_cooldown
}


module "autoscaling-eu" {
  source      = "../../modules/autoscaling"
  ecs_cluster = "nginx_hello_world_eu"
  ecs_service = "nginx_hello_world_eu"
  min_capacity = var.min_capacity
  max_capacity = var.max_capacity
  target_value = var.target_value
  scale_in_cooldown = var.scale_in_cooldown
  scale_out_cooldown = var.scale_out_cooldown
}

# module "flow-logs-eu" {
#   source   = "../../modules/flow-logs"
#   main_vpc = module.us-east-1.main_vpc_id
# }

# module "flow-logs-us" {
#   source   = "../../modules/flow-logs"
#   main_vpc = module.eu-west-1.main_vpc_id
# }

# module "s3-storage" {
#   source = "../../modules/s3-storage"
#   bucket_name = var.bucket_name
# }

