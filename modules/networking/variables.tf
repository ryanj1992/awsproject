variable "access_ip" {}
variable "environment" {}
variable "vpc_peer_id" {}
variable "bucket_name" {}

variable ingress {
  type        = list(object({
        rule_no    = number
        action     = string
        from_port  = number
        to_port    = number
  }))
  default   = [
    {
        rule_no    = 100
        action     = "allow"
        from_port  = 80
        to_port    = 80
    },

    {
        rule_no    = 120
        action     = "allow"
        from_port  = 443
        to_port    = 443
    },

    {
        rule_no    = 110
        action     = "allow"
        from_port  = 1024
        to_port    = 65535
    }]
}

variable egress {
  type        = list(object({
        rule_no    = number
        action     = string
        from_port  = number
        to_port    = number
  }))
  default   = [
    {
        rule_no    = 100
        action     = "allow"
        from_port  = 80
        to_port    = 80
    },

    {
        rule_no    = 120
        action     = "allow"
        from_port  = 443
        to_port    = 443
    },

    {
        rule_no    = 110
        action     = "allow"
        from_port  = 1024
        to_port    = 65535
    }]
}