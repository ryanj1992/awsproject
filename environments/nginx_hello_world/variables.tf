# Environment vars
variable "aws_region" {}

# ECS vars
variable "launch_type" {}
variable "application_name" {}
variable "container_image" {}
variable "container_name" {}
variable "port_mappings" {
  type = list(map(string))
}
variable "cpu" {}
variable "memory" {}
variable "network_mode" {}

# Networking vars
# variable "cidr_block" {}
# variable "private_cidrs" {
#   type = list(any)
# }
# variable "public_cidrs" {
#   type = list(any)
# }
variable "access_ip" {}
# variable "environment" {}


# Autoscaling variables

variable "min_capacity" {}
variable "max_capacity" {}
variable "target_value" {}
variable "scale_in_cooldown" {}
variable "scale_out_cooldown" {}

# S3 Variables

# variable "bucket_name" {}