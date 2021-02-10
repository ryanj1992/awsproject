module "networking" {
  source       = "../modules/networking"
  vpc_cidr     = var.vpc_cidr
  public_cidrs = var.public_cidrs
  accessip     = var.access_ip
}

module "ecs" {
    source = "../modules/ecs"
}