variable cidr_block {
  type        = string
  default     = "10.0.0.0/16"
}

variable environment {
  type        = string
  default     = "us-east"
}

variable private_cidrs {
  type        = list
  default     = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

variable access_ip {
  type        = string
  default     = "0.0.0.0/0"
}

variable "application_name" {
    default = "nginx-helloworld"
}

variable "launch_type" {
    default = "FARGATE"
}
