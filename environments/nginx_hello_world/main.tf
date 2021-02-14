module "us-east-1" {
    for_each = toset( ["us-east-1", "eu-west-1"] )
    source = "../../modules/networking"
    environment   = each.key
    vpc_peer_id = module.vpc-peering.vpc_peer_id
    # bucket_name = module.s3-storage.alb_logs_bucket
    access_ip     = var.access_ip
    providers = {
        aws = aws.us-east-1
    }
}

module "vpc-peering" {
  source = "../../modules/vpc-peering"
  # peer_owner_id = var.peer_owner_id
  peer_vpc_id   = module.us-east-1["us-east-1"].main_vpc_id
  vpc_id        = module.us-east-1["eu-west-1"].main_vpc_id
}

# module "s3-storage" {
#   for_each = toset( ["us-east-1", "eu-west-1"] )
#   source = "../../modules/s3-storage"
#   environment   = each.key
#   # bucket_name = var.bucket_name
# }

# module "ecs-us" {
#   source           = "../../modules/ecs"
#   environment      = "us-east-1"
#   application_name = "nginx_hello_world_us"
#   launch_type      = var.launch_type
#   container_image  = var.container_image
#   container_name   = var.container_name
#   port_mappings    = var.port_mappings
#   cpu              = var.cpu
#   memory           = var.memory
#   network_mode     = var.network_mode
#   public_alb       = module.us-east-1.public_lb_arn
#   main_vpc         = module.us-east-1.main_vpc_id
#   security_group   = module.us-east-1.private_sg_id
#   private_subnet   = module.us-east-1.private_subnet_id
# }

# module "ecs-eu" {
#   source           = "../../modules/ecs"
#   environment   = "eu-west-1"
#   application_name = "nginx_hello_world_eu"
#   launch_type      = var.launch_type
#   container_image  = var.container_image
#   container_name   = var.container_name
#   port_mappings    = var.port_mappings
#   cpu              = var.cpu
#   memory           = var.memory
#   network_mode     = var.network_mode
#   public_alb       = module.eu-west-1.public_lb_arn
#   main_vpc         = module.eu-west-1.main_vpc_id
#   security_group   = module.eu-west-1.private_sg_id
#   private_subnet   = module.eu-west-1.private_subnet_id
# }

# module "autoscaling-us" {
#   source      = "../../modules/autoscaling"
#   ecs_cluster = "nginx_hello_world_us"
#   ecs_service = "nginx_hello_world_us"
#   min_capacity = var.min_capacity
#   max_capacity = var.max_capacity
#   target_value = var.target_value
#   scale_in_cooldown = var.scale_in_cooldown
#   scale_out_cooldown = var.scale_out_cooldown
# }


# module "autoscaling-eu" {
#   source      = "../../modules/autoscaling"
#   ecs_cluster = "nginx_hello_world_eu"
#   ecs_service = "nginx_hello_world_eu"
#   min_capacity = var.min_capacity
#   max_capacity = var.max_capacity
#   target_value = var.target_value
#   scale_in_cooldown = var.scale_in_cooldown
#   scale_out_cooldown = var.scale_out_cooldown
# }

# module "route53" {
#   source = "../../modules/route53"
#   dns_name = module.us-east-1.public_alb_dns_name
#   zone_id = module.us-east-1.public_alb_zone_id
# }

# module "route53" {
#   source = "../../modules/route53"
#   dns_name = module.eu-west-1.public_alb_dns_name
#   zone_id = module.eu-west-1.public_alb_zone_id
# }

# module "flow-logs-eu" {
#   source   = "../../modules/flow-logs"
#   main_vpc = module.us-east-1.main_vpc_id
# }

# module "flow-logs-us" {
#   source   = "../../modules/flow-logs"
#   main_vpc = module.eu-west-1.main_vpc_id
# }

