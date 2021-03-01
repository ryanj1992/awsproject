# variable "application_name" {}
variable "launch_type" {}
variable "container_name" {}
variable "port_mappings" {}
variable "cpu" {}
variable "memory" {}
variable "network_mode" {}

# Outputs from networking
variable "public_alb" {}
variable "security_group" {}
variable "private_subnet" {}
variable "main_vpc" {}
variable "environment" {}
variable "efs_id" {}

# Outputs from endpoints

variable "execution_role_arn" {}