#---------------------------------- NETWORKING

data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support = true

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
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.*.id[0] # Needs looking at
  }
  
  tags = {
    Name = "${var.environment}_private_rt"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  
  tags = {
    Name = "${var.environment}_public_rt"
  }
}

resource "aws_subnet" "private_subnet" {
  count = 2
  vpc_id = aws_vpc.main.id
  cidr_block = var.private_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.environment}_private_subnet_${count.index + 1}"
  }
}

resource "aws_subnet" "public_subnet" {
  count = length(aws_subnet.private_subnet)
  vpc_id = aws_vpc.main.id
  cidr_block = var.public_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.environment}_public_subnet_${count.index + 1}"
  }
}

resource "aws_eip" "ngw" {
  count = length(aws_subnet.private_subnet)
  vpc      = true
}

resource "aws_nat_gateway" "ngw" {
  count = length(aws_subnet.private_subnet)
  allocation_id = aws_eip.ngw.*.id[count.index]
  subnet_id = aws_subnet.public_subnet.*.id[count.index]

  depends_on = [aws_internet_gateway.gw]

  tags = {
    Name = "${var.environment}_ngw_${count.index + 1}"
  }
}

resource "aws_route_table_association" "private_assoc" {
  count = length(aws_subnet.private_subnet)
  subnet_id = aws_subnet.private_subnet.*.id[count.index]
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "public_assoc" {
  count = length(aws_subnet.public_subnet)
  subnet_id = aws_subnet.public_subnet.*.id[count.index]
  route_table_id = aws_route_table.public_rt.id
}

# Public association table here

resource "aws_security_group" "private_security_group" {
  vpc_id = aws_vpc.main.id

  ingress {
    protocol   = "tcp"
    cidr_blocks = [var.access_ip]
    from_port  = 80
    to_port    = 80
  }

# Might need updating when NAT added
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1" # all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}_private_sg"
  }
}

# Create security group for ALB

resource "aws_lb" "public_alb" {
  name = "${var.environment}-public-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.private_security_group.id] # Change to security group for ALB
  subnets = aws_subnet.public_subnet.*.id # Change to public subnets

  # LOGS FOR LOAD BALANCER
  # access_logs {
  #   bucket  = aws_s3_bucket.lb_logs.bucket
  #   prefix  = "${var.environment}-public-alb"
  #   enabled = true
  # }

  tags = {
    Name = "${var.environment}_public_alb"
  }
}