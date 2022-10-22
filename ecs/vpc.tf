# vpc.tf | VPC Configuration

resource "aws_vpc" "default" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "terraform-${var.infra_env}-vpc"
    Environment = var.infra_env
    ManagedBy   = "terraform"
  }
}

resource "aws_subnet" "public" {
  for_each = var.public_subnet_numbers

  vpc_id            = aws_vpc.default.id
  availability_zone = each.key

  # 4,000 IP addresses each
  cidr_block = cidrsubnet(aws_vpc.default.cidr_block, 4, each.value)

  tags = {
    Name        = "terraform-${var.infra_env}-public-subnet"
    Role        = "public"
    Environment = var.infra_env
    ManagedBy   = "terraform"
    Subnet      = "${each.key}-${each.value}"
  }
}

resource "aws_subnet" "private" {
  for_each = var.private_subnet_numbers

  vpc_id            = aws_vpc.default.id
  availability_zone = each.key

  # 2,048 IP addresses each
  cidr_block = cidrsubnet(aws_vpc.default.cidr_block, 4, each.value)

  tags = {
    Name        = "terraform-${var.infra_env}-private-subnet"
    Role        = "private"
    Environment = var.infra_env
    ManagedBy   = "terraform"
    Subnet      = "${each.key}-${each.value}"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name        = "terraform-${var.infra_env}-internet-gateway"
    Environment = var.infra_env
    ManagedBy   = "terraform"
  }
}

resource "aws_route_table" "public" {
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }

  tags = {
    Name        = "terraform-${var.infra_env}-route-table-public"
    Environment = var.infra_env
    ManagedBy   = "terraform"
  }

  vpc_id = aws_vpc.default.id
}

resource "aws_route_table" "private" {
  tags = {
    Name        = "terraform-${var.infra_env}-route-table-private"
    Environment = var.infra_env
    ManagedBy   = "terraform"
  }

  vpc_id = aws_vpc.default.id
}

resource "aws_route_table_association" "public" {
  route_table_id = aws_route_table.public.id
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
}

resource "aws_route_table_association" "private" {
  route_table_id = aws_route_table.private.id
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
}

resource "aws_main_route_table_association" "default" {
  route_table_id = aws_route_table.public.id
  vpc_id         = aws_vpc.default.id
}

data "aws_subnets" "subnets" {
  filter {

    name   = "vpc-id"
    values = [aws_vpc.default.id]
  }
}

data "aws_subnet" "subnet_values" {
  for_each = toset(data.aws_subnets.subnets.ids)
  id       = each.value
}
