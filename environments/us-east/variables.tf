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
variable "cidr_block" {}
variable "private_cidrs" {
  type = list(any)
}
variable "public_cidrs" {
  type = list(any)
}
variable "access_ip" {}
variable "environment" {}
