resource "aws_vpc" "new-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.prefix}-vpc"
  }
}

locals {
  tags_prod = {
    Project = "Nest Terraform"
    Environment = "Production"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "public_subnets" {
  count = 2
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = aws_vpc.new-vpc.id
  cidr_block = cidrsubnet(aws_vpc.new-vpc.cidr_block, 8, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.prefix}-public-subnet-${count.index}"
  }
}

resource "aws_subnet" "private_subnets" {
  count                   = 2
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = aws_vpc.new-vpc.id
  cidr_block              = "10.0.${count.index + 2}.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.prefix}-private-subnet-${count.index}"
  }
}

resource "aws_internet_gateway" "new-igw" {
  vpc_id = aws_vpc.new-vpc.id
  tags = {
    Name = "${var.prefix}-igw"
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = merge(local.tags_prod, { Name = "${var.prefix}-nat-eip" })
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnets[0].id
}

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.new-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.new-igw.id
  }
  tags = {
    Name = "${var.prefix}-public-rtb"
  }
}

resource "aws_route_table_association" "public-route-table-association" {
  count = 2
  route_table_id = aws_route_table.public-route-table.id
  subnet_id = aws_subnet.public_subnets[count.index].id
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.new-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = merge(local.tags_prod, { Name = "${var.prefix}-private-rt" })
}

resource "aws_route_table_association" "private-route-table-association" {
  count = 2
  route_table_id = aws_route_table.private-route-table.id
  subnet_id = aws_subnet.private_subnets[count.index].id
  lifecycle {
    create_before_destroy = true
  }
}