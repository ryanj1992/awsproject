# Environment vars
variable "aws_region" {}

# ECS vars
variable "launch_type" {}
variable "application_name" {}
variable "container_name" {}
variable "port_mappings" {
  type = list(map(string))
}
variable "cpu" {}
variable "memory" {}
variable "network_mode" {}

# Autoscaling variables

variable "min_capacity" {}
variable "max_capacity" {}
variable "target_value" {}
variable "scale_in_cooldown" {}
variable "scale_out_cooldown" {}

# Networking variables

variable "access_ip" {}
variable "nacl_ingress" {}
variable "nacl_egress" {}
variable "sg_ingress" {}
