module "networking" {
  source        = "../../modules/networking"
  cidr_block    = var.cidr_block
  private_cidrs = var.private_cidrs
  public_cidrs  = var.public_cidrs
  access_ip     = var.access_ip
  environment   = var.environment
  # bucket_name = var.bucket_name
}

module "ecs" {
  source           = "../../modules/ecs"
  environment      = var.environment
  application_name = var.application_name
  launch_type      = var.launch_type
  container_image  = var.container_image
  container_name   = var.container_name
  port_mappings    = var.port_mappings
  cpu              = var.cpu
  memory           = var.memory
  network_mode     = var.network_mode
  public_alb       = module.networking.public_lb_arn
  main_vpc         = module.networking.main_vpc_id
  security_group   = module.networking.private_sg_id
  private_subnet   = module.networking.private_subnet_id
}

module "autoscaling" {
  source      = "../../modules/autoscaling"
  ecs_cluster = var.application_name
  ecs_service = var.application_name
  min_capacity = var.min_capacity
  max_capacity = var.max_capacity
  target_value = var.target_value
  scale_in_cooldown = var.scale_in_cooldown
  scale_out_cooldown = var.scale_out_cooldown
}

module "flow-logs" {
  source   = "../../modules/flow-logs"
  main_vpc = module.networking.main_vpc_id
}

# module "s3-storage" {
#   source = "../../modules/s3-storage"
#   bucket_name = var.bucket_name
# }

