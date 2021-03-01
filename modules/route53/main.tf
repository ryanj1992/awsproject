locals {
  zone_name = var.environment == "us-east-1" ? "nginx-hello-world-us.com" : "nginx-hello-world-eu.com" # will need changing when going live
}

resource "aws_route53_zone" "primary" { # only needs to be created once!?!?!?!?!?!
  name = local.zone_name                # Domain name?
}

resource "aws_route53_record" "us-east-1-lb" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "example.com" # Domain name, maybe www?
  type    = "A"

  latency_routing_policy {
    region = var.environment # Region loadbalancer is in
  }

  alias {
    name                   = var.dns_name
    zone_id                = var.zone_id
    evaluate_target_health = true
  }
}