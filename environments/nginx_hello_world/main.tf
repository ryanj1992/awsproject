module "networking" {
    for_each = toset( ["us-east-1", "eu-west-1"] )
    source = "../../modules/networking"
    environment   = each.key
    vpc_peer_id = module.vpc-peering.vpc_peer_id
    bucket_name = module.s3-storage[each.key].alb_logs_bucket
    access_ip     = var.access_ip
    providers = {
        aws = aws.us-east-1
    }
}

module "vpc-peering" {
  source = "../../modules/vpc-peering"
  # peer_owner_id = var.peer_owner_id
  peer_vpc_id   = module.networking["us-east-1"].main_vpc_id
  vpc_id        = module.networking["eu-west-1"].main_vpc_id
}

module "ecs-us" {
  for_each = toset( ["us-east-1", "eu-west-1"] )
  source           = "../../modules/ecs"
  environment      = each.key
  launch_type      = var.launch_type
  container_image  = var.container_image
  container_name   = var.container_name
  port_mappings    = var.port_mappings
  cpu              = var.cpu
  memory           = var.memory
  network_mode     = var.network_mode
  public_alb       = module.networking[each.key].public_lb_arn
  main_vpc         = module.networking[each.key].main_vpc_id
  security_group   = module.networking[each.key].private_sg_id
  private_subnet   = module.networking[each.key].private_subnet_id
}

# module "autoscaling-us" {
#   for_each = toset( ["us-east-1", "eu-west-1"] )
#   source      = "../../modules/autoscaling"
#   environment = each.key
#   min_capacity = var.min_capacity
#   max_capacity = var.max_capacity
#   target_value = var.target_value
#   scale_in_cooldown = var.scale_in_cooldown
#   scale_out_cooldown = var.scale_out_cooldown
# }

module "s3-storage" {
  for_each = toset( ["us-east-1", "eu-west-1"] )
  source = "../../modules/s3-storage"
  environment   = each.key
}

# module "flow-logs-eu" {
#   for_each = toset( ["us-east-1", "eu-west-1"] )
#   source   = "../../modules/flow-logs"
#   environment = each.key
#   main_vpc = module.networking[each.key].main_vpc_id
# }

# module "route53" {
#   for_each = toset( ["us-east-1", "eu-west-1"] )
#   source = "../../modules/route53"
#   environment = each.key
#   dns_name = module.networking[each.key].public_alb_dns_name
#   zone_id = module.networking[each.key].public_alb_zone_id
# }
