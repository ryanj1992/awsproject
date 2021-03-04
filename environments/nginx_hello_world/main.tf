module "networking-us" {
  source       = "../../modules/networking"
  environment  = "us-east-1"
  bucket_name  = module.s3-storage-us.alb_logs_bucket
  access_ip    = var.access_ip
  nacl_ingress = var.nacl_ingress
  nacl_egress  = var.nacl_egress
  sg_ingress   = var.sg_ingress
  # vpc_peer_id  = module.vpc-peering.vpc_peer_id

  providers = {
    aws = aws.us-east-1 # change this to each.key and add to other modules
  }
}

module "ecs-us" {
  source             = "../../modules/ecs"
  environment        = "us-east-1"
  launch_type        = var.launch_type
  container_name     = var.container_name
  port_mappings      = var.port_mappings
  cpu                = var.cpu
  memory             = var.memory
  network_mode       = var.network_mode
  execution_role_arn = module.iam-roles.role_arn
  public_alb         = module.networking-us.public_lb_arn
  main_vpc           = module.networking-us.main_vpc_id
  security_group     = module.networking-us.private_sg_id
  private_subnet     = module.networking-us.private_subnet_id
  efs_id             = module.networking-us.efs_id

  providers = {
    aws = aws.us-east-1
  }
}

module "s3-storage-us" {
  source      = "../../modules/s3-storage"
  environment = "us-east-1"

  providers = {
    aws = aws.us-east-1
  }
}

module "endpoints-us" { # needs updating with each.key
  environment = "us-east-1"
  source            = "../../modules/endpoints"
  security_group    = module.networking-us.private_sg_id
  vpc_id            = module.networking-us.main_vpc_id
  private_subnet_id = module.networking-us.private_subnet_id

  providers = {
    aws = aws.us-east-1
  }
}

module "autoscaling-us" {
  source      = "../../modules/autoscaling"
  environment = "us-east-1"
  min_capacity = var.min_capacity
  max_capacity = var.max_capacity
  target_value = var.target_value
  scale_in_cooldown = var.scale_in_cooldown
  scale_out_cooldown = var.scale_out_cooldown

  providers = {
    aws = aws.us-east-1
  }
}

# # --------------------------------------- EU WEST

module "networking-eu" {
  source       = "../../modules/networking"
  environment  = "eu-west-1"
  bucket_name  = module.s3-storage-eu.alb_logs_bucket
  access_ip    = var.access_ip
  nacl_ingress = var.nacl_ingress
  nacl_egress  = var.nacl_egress
  sg_ingress   = var.sg_ingress
  # vpc_peer_id  = module.vpc-peering.vpc_peer_id

  providers = {
    aws = aws.eu-west-1 # change this to each.key and add to other modules
  }
}

module "ecs-eu" {
  source             = "../../modules/ecs"
  environment        = "eu-west-1"
  launch_type        = var.launch_type
  container_name     = var.container_name
  port_mappings      = var.port_mappings
  cpu                = var.cpu
  memory             = var.memory
  network_mode       = var.network_mode
  execution_role_arn = module.iam-roles.role_arn
  public_alb         = module.networking-eu.public_lb_arn
  main_vpc           = module.networking-eu.main_vpc_id
  security_group     = module.networking-eu.private_sg_id
  private_subnet     = module.networking-eu.private_subnet_id
  efs_id             = module.networking-eu.efs_id

  providers = {
    aws = aws.eu-west-1
  }
}

module "s3-storage-eu" {
  source      = "../../modules/s3-storage"
  environment = "eu-west-1"

  providers = {
    aws = aws.eu-west-1
  }
}

module "endpoints-eu" { # needs updating with each.key
  environment = "eu-west-1"
  source            = "../../modules/endpoints"
  security_group    = module.networking-eu.private_sg_id
  vpc_id            = module.networking-eu.main_vpc_id
  private_subnet_id = module.networking-eu.private_subnet_id

  providers = {
    aws = aws.eu-west-1
  }
}

module "autoscaling-eu" {
  source      = "../../modules/autoscaling"
  environment = "eu-west-1"
  min_capacity = var.min_capacity
  max_capacity = var.max_capacity
  target_value = var.target_value
  scale_in_cooldown = var.scale_in_cooldown
  scale_out_cooldown = var.scale_out_cooldown

  providers = {
    aws = aws.eu-west-1
  }
}

# ---------------------- IAM ROLES

module "iam-roles" {
  source = "../../modules/iam-roles"
}

module "route53" {
  source = "../../modules/route53"
  us_lb_dns_name = module.networking-us.public_alb_dns_name
  us_lb_zone_id = module.networking-us.public_alb_zone_id
  eu_lb_dns_name = module.networking-eu.public_alb_dns_name
  eu_lb_zone_id = module.networking-eu.public_alb_zone_id
}

# module "vpc-peering" {
#   source = "../../modules/vpc-peering"
#   # peer_owner_id = var.peer_owner_id
#   peer_vpc_id = module.networking["us-east-1"].main_vpc_id
#   vpc_id      = module.networking["eu-west-1"].main_vpc_id
# }

# module "flow-logs-eu" {
#   for_each = toset( ["us-east-1", "eu-west-1"] )
#   source   = "../../modules/flow-logs"
#   environment = each.key
#   main_vpc = module.networking[each.key].main_vpc_id

# providers {
#   aws = aws."${each.key}"
# }
# }

# module "athena" {
#   source = "../../modules/athena"
#   # s3bucket = module.s3-storage.alb_logs_bucket
# }
