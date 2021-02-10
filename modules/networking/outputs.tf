output "private_subnet_id" {
    value = aws_subnet.private_subnet.*.id
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