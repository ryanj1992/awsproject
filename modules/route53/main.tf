data "aws_route53_zone" "primary" {
  name = "rj.wren.cloud"
}

resource "aws_route53_record" "us_latency" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "nginx" # the name of the record
  type    = "A"


  set_identifier = "us_latency_lb"
  latency_routing_policy {
    region = "us-east-1" # Region loadbalancer is in
  }

  alias {
    name                   = var.us_lb_dns_name
    zone_id                = var.us_lb_zone_id
    evaluate_target_health = true
  }
}

# resource "aws_route53_record" "eu_latency" {
#   zone_id = data.aws_route53_zone.primary.zone_id
#   name    = "nginx" # the name of the record
#   type    = "A"

#   latency_routing_policy {
#     region = "eu-west-1" # Region loadbalancer is in
#   }

#   set_identifier = "eu_latency_lb"
#   alias {
#     name                   = var.eu_lb_dns_name
#     zone_id                = var.eu_lb_zone_id
#     evaluate_target_health = true
#   }
# }