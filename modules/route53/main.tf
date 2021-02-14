locals {
  zone_name = var.environment == "us-east-1" ? "nginx-hello-world-us.com" : "nginx-hello-world-eu.com" # will need changing when going live
}

resource "aws_route53_zone" "primary" { # only needs to be created once!?!?!?!?!?!
  name = local.zone_name
}

resource "aws_route53_record" "us-east-1-lb" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "example.com"
  type    = "A"

  alias {
    name                   = aws_elb.main.dns_name
    zone_id                = aws_elb.main.zone_id
    evaluate_target_health = true
  }
}