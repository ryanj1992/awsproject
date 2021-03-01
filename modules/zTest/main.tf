

locals {
  public_cidrs  = { us-east-1a = "10.0.1.0/24", us-east-1b = "10.0.2.0/24" }
  private_cidrs = { us-east-1a = "10.0.3.0/24", us-east-1b = "10.0.4.0/24" }
  cidr_block    = "10.0.0.0/16"
}

resource "aws_vpc" "main" {
  cidr_block           = local.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "us-east-1_vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "us_east_1_gw"
  }
}


resource "aws_subnet" "public_subnet" {
  for_each          = tomap(local.public_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = {
    Name = "${each.key}_public_subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  for_each          = tomap(local.private_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = {
    Name = "${each.key}_private_subnet"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  # route {
  #   cidr_block     = local.peer_cidr
  #   vpc_peering_connection_id = var.vpc_peer_id
  # }

  tags = {
    Name = "us-east-1_public_rt"
  }
}

resource "aws_route_table" "private_rt" {
  for_each = aws_subnet.private_subnet
  vpc_id   = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw[each.key].id
  }

  tags = {
    Name = "${each.key}_private_rt"
  }
}

resource "aws_network_acl" "public_nacl" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [for zone in aws_subnet.public_subnet : zone.id]

  dynamic "ingress" {
    for_each = var.ingress
    content {
      protocol   = "tcp"
      rule_no    = ingress.value.rule_no
      action     = ingress.value.action
      cidr_block = ingress.value.cidr_block
      from_port  = ingress.value.from_port
      to_port    = ingress.value.to_port
    }
  }

  dynamic "egress" {
    for_each = var.egress
    content {
      protocol   = "tcp"
      rule_no    = egress.value.rule_no
      action     = egress.value.action
      cidr_block = egress.value.cidr_block
      from_port  = egress.value.from_port
      to_port    = egress.value.to_port
    }
  }

  tags = {
    Name = "us-east-1_public_nacl"
  }
}

resource "aws_eip" "ngw" {
  for_each = aws_subnet.private_subnet
  vpc      = true
}


resource "aws_nat_gateway" "ngw" {
  for_each      = aws_subnet.public_subnet
  allocation_id = aws_eip.ngw[each.key].id
  subnet_id     = each.value.id

  depends_on = [aws_internet_gateway.gw]

  tags = {
    Name = "${each.key}_ngw"
  }
}

resource "aws_route_table_association" "private_assoc" {
  for_each       = aws_subnet.private_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rt[each.key].id
}


resource "aws_route_table_association" "public_assoc" {
  for_each       = aws_subnet.public_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "private_security_group" {
  vpc_id = aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
  }

  # Might need updating when NAT added
  egress {
    protocol    = "-1" # all protocols
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
  }

  tags = {
    Name = "us-east-1_private_sg"
  }
}

resource "aws_lb" "public_alb" {
  name               = "us-east-1-public-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.private_security_group.id] # Change to security group for ALB
  subnets            = [for zone in aws_subnet.public_subnet : zone.id]

  # # LOGS FOR LOAD BALANCER
  # access_logs {
  #   bucket  = var.bucket_name
  #   enabled = true
  # }

  tags = {
    Name = "us-east-1_public_alb"
  }
}