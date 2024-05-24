resource "aws_internet_gateway" "wordpress-vpc-igw" {
  vpc_id = aws_vpc.wordpress-vpc.id
  tags = merge(var.tags, {
    Name        = "wordpress-vpc-igw"
    Environment = "production"
    Company     = "Clevertap"
    VPC         = "wordpress-vpc"
  })
}

resource "aws_subnet" "public_b" {
  vpc_id = aws_vpc.wordpress-vpc.id
  tags = merge(var.tags, {
    Name        = "public-b"
    Environment = "production"
    Company     = "Clevertap"
    VPC         = "wordpress-vpc"
  })
  cidr_block        = var.subnets.b
  availability_zone = "us-west-2b"
}

resource "aws_subnet" "public_a" {
  vpc_id = aws_vpc.wordpress-vpc.id
  tags = merge(var.tags, {
    Name        = "public-a"
    Environment = "production"
    Company     = "Clevertap"
    VPC         = "wordpress-vpc"
  })
  cidr_block        = var.subnets.a
  availability_zone = "us-west-2a"
}

resource "aws_eip" "eip_b" {
  tags = merge(var.tags, {
    Name        = "eip-b"
    Environment = "production"
    Company     = "Clevertap"
    VPC         = "wordpress-vpc"
  })
}

resource "aws_eip" "eip_a" {
  tags = merge(var.tags, {
    Name        = "eip-a"
    Environment = "production"
    Company     = "Clevertap"
    VPC         = "wordpress-vpc"
  })
}

resource "aws_nat_gateway" "nat-gw-2a-public" {
  allocation_id = aws_eip.eip_a.id
  subnet_id     = aws_subnet.public_a.id
  tags = merge(var.tags, {
    Name        = "nat-gw-2a-public"
    Environment = "production"
    Company     = "Clevertap"
    VPC         = "wordpress-vpc"
  })
  depends_on = [aws_eip.eip_a]
}

resource "aws_nat_gateway" "nat-gw-2b-public" {
  allocation_id = aws_eip.eip_b.id
  subnet_id     = aws_subnet.public_b.id
  tags = merge(var.tags, {
    Name        = "nat-gw-2b-public"
    Environment = "production"
    Company     = "Clevertap"
    VPC         = "wordpress-vpc"
  })
  depends_on = [aws_eip.eip_b]
}

resource "aws_route_table" "rt_public_a" {
  vpc_id = aws_vpc.wordpress-vpc.id
}

resource "aws_route_table_association" "rt_assoc_public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.rt_public_a.id
}

resource "aws_route" "route_a" {
  route_table_id         = aws_route_table.rt_public_a.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.wordpress-vpc-igw.id
}

resource "aws_route_table" "rt_public_b" {
  vpc_id = aws_vpc.wordpress-vpc.id
  tags = merge(var.tags, {
    Name        = "rt-public-b"
    Environment = "production"
    Company     = "Clevertap"
    VPC         = "wordpress-vpc"
  })
}

resource "aws_route_table_association" "rt_assoc_public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.rt_public_b.id
}

resource "aws_route" "route_b" {
  route_table_id         = aws_route_table.rt_public_b.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.wordpress-vpc-igw.id
}


