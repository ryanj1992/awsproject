data "aws_route53_zone" "primary" { # only needs to be created once!?!?!?!?!?!
  name = "rj.wren.cloud"                # Domain name?
}

resource "aws_route53_record" "us_latency" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "example.com" # the name of the record
  type    = "A"


  set_identifier = "us_latency"
  latency_routing_policy {
    region = var.environment # Region loadbalancer is in
  }

  alias {
    name                   = var.us_lb_dns_name
    zone_id                = var.us_lb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "eu_latency" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "example.com" # the name of the record
  type    = "A"

  latency_routing_policy {
    region = var.environment # Region loadbalancer is in
  }

  set_identifier = "eu_latency"
  alias {
    name                   = var.eu_lb_dns_name
    zone_id                = var.eu_lb_zone_id
    evaluate_target_health = true
  }
}

# ---------------------- FAILOVER

resource "aws_route53_record" "eu_failover" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "www1" # the name of the record
  type    = "A"


  failover_routing_policy {
    type = "PRIMARY"
  }

  set_identifier = "eu_failover"
  alias {
    name                   = var.eu_lb_dns_name
    zone_id                = var.eu_lb_zone_id
    evaluate_target_health = true
  }

}

resource "aws_route53_record" "us_failover" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "www2" # the name of the record
  type    = "A"

  failover_routing_policy {
    type = "SECONDARY"
  }

  set_identifier = "us_failover"
  alias {
    name                   = var.us_lb_dns_name
    zone_id                = var.us_lb_zone_id
    evaluate_target_health = true
  }
}