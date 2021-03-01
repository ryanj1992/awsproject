output "private_subnet_id" {
  value = [for zone in aws_subnet.private_subnet : zone.id]
}

output "private_sg_id" {
  value = aws_security_group.private_security_group.id
}

output "main_vpc_id" {
  value = aws_vpc.main.id
}

output "public_lb_arn" {
  value = aws_lb.public_alb.arn
}

output "public_alb_dns_name" {
  value = aws_lb.public_alb.dns_name
}

output "public_alb_zone_id" {
  value = aws_lb.public_alb.zone_id
}

output "efs_id" {
  value = aws_efs_file_system.ecs_efs.id
}