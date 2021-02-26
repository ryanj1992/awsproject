variable "access_ip" {}
variable "environment" {}
variable "vpc_peer_id" {}
variable "bucket_name" {}

variable nacl_ingress {
  type        = list(object({
        rule_no    = number
        action     = string
        from_port  = number
        to_port    = number
  }))
}

variable nacl_egress {
  type        = list(object({
        rule_no    = number
        action     = string
        from_port  = number
        to_port    = number
  }))
}

variable sg_ingress {
  type        = list(object({
        protocol   = string
        from_port  = number
        to_port    = number
  }))
}