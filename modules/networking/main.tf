#---------------------------------- NETWORKING

data "aws_availability_zones" "available" {}

locals {
   public_cidrs = var.environment == "us-east-1" ? ["10.0.1.0/24", "10.0.2.0/24"] : ["10.1.1.0/24", "10.1.2.0/24"]
   private_cidrs = var.environment == "us-east-1" ? ["10.0.3.0/24", "10.0.4.0/24"] : ["10.1.3.0/24", "10.1.4.0/24"]
   cidr_block = var.environment == "us-east-1" ? "10.0.0.0/16" : "10.1.0.0/16"
   peer_cidr = var.environment == "us-east-1" ? "10.1.0.0/16" : "10.0.0.0/16"

}


resource "aws_vpc" "main" {
  cidr_block           = local.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.environment}_vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.environment}_gw"
  }
}

resource "aws_route_table" "private_rt" {
  count  = length(aws_subnet.private_subnet)
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.*.id[count.index]
  }

  tags = {
    Name = "${var.environment}_private_rt_${count.index + 1}"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    cidr_block     = local.peer_cidr
    vpc_peering_connection_id = var.vpc_peer_id
  }

  tags = {
    Name = "${var.environment}_public_rt"
  }
}

resource "aws_network_acl" "public_nacl" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = concat(aws_subnet.public_subnet.*.id, aws_subnet.private_subnet.*.id)

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.access_ip
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = var.access_ip
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = var.access_ip
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.access_ip
    from_port  = 80
    to_port    = 80
  }

  egress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = var.access_ip
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = var.access_ip
    from_port  = 443
    to_port    = 443
  }

  tags = {
    Name = "${var.environment}_public_nacl"
  }
}

resource "aws_subnet" "private_subnet" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.private_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.environment}_private_subnet_${count.index + 1}"
  }
}

resource "aws_subnet" "public_subnet" {
  count             = length(aws_subnet.private_subnet)
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.public_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.environment}_public_subnet_${count.index + 1}"
  }
}

resource "aws_eip" "ngw" {
  count = length(aws_subnet.private_subnet)
  vpc   = true
}

resource "aws_nat_gateway" "ngw" {
  count         = length(aws_subnet.private_subnet)
  allocation_id = aws_eip.ngw.*.id[count.index]
  subnet_id     = aws_subnet.public_subnet.*.id[count.index]

  depends_on = [aws_internet_gateway.gw]

  tags = {
    Name = "${var.environment}_ngw_${count.index + 1}"
  }
}

resource "aws_route_table_association" "private_assoc" {
  count          = length(aws_subnet.private_subnet)
  subnet_id      = aws_subnet.private_subnet.*.id[count.index]
  route_table_id = aws_route_table.private_rt.*.id[count.index]
}

resource "aws_route_table_association" "public_assoc" {
  count          = length(aws_subnet.public_subnet)
  subnet_id      = aws_subnet.public_subnet.*.id[count.index]
  route_table_id = aws_route_table.public_rt.id
}

# Public association table here

resource "aws_security_group" "private_security_group" {
  vpc_id = aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    cidr_blocks = [var.access_ip]
    from_port   = 80
    to_port     = 80
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = [var.access_ip]
    from_port   = 443
    to_port     = 443
  }
  
  # Might need updating when NAT added
  egress {
    protocol    = "-1" # all protocols
    cidr_blocks = [var.access_ip]
    from_port   = 0
    to_port     = 0
  }

  tags = {
    Name = "${var.environment}_private_sg"
  }
}

# Create security group for ALB

resource "aws_lb" "public_alb" {
  name               = "${var.environment}-public-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.private_security_group.id] # Change to security group for ALB
  subnets            = aws_subnet.public_subnet.*.id

  # LOGS FOR LOAD BALANCER
  # access_logs {
  #   bucket  = var.bucket_name
  #   # prefix  = "${var.environment}-public-alb"
  #   enabled = true
  # }

  tags = {
    Name = "${var.environment}_public_alb"
  }
}

