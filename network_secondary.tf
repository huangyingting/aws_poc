resource "aws_vpc" "secondary" {
  cidr_block           = "172.17.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Project = "aws-poc"
  }
  provider = aws.sydney
}

resource "aws_internet_gateway" "secondary" {
  vpc_id = aws_vpc.secondary.id
  tags = {
    Project = "aws-poc"
  }
  provider = aws.sydney
}

resource "aws_route_table" "pub_rt_2" {
  vpc_id = aws_vpc.secondary.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.secondary.id
  }
  tags = {
    Project = "aws-poc"
  }
  provider = aws.sydney
}

resource "aws_subnet" "pub_sub_2a" {
  vpc_id                  = aws_vpc.secondary.id
  cidr_block              = "172.17.11.0/24"
  availability_zone       = "ap-southeast-2a"
  map_public_ip_on_launch = true
  tags = {
    Project = "aws-poc"
  }
  provider = aws.sydney
}

resource "aws_subnet" "web_prv_sub_2a" {
  vpc_id                  = aws_vpc.secondary.id
  cidr_block              = "172.17.12.0/24"
  availability_zone       = "ap-southeast-2a"
  map_public_ip_on_launch = false
  tags = {
    Project = "aws-poc"
  }
  provider = aws.sydney
}

resource "aws_subnet" "app_prv_sub_2a" {
  vpc_id                  = aws_vpc.secondary.id
  cidr_block              = "172.17.13.0/24"
  availability_zone       = "ap-southeast-2a"
  map_public_ip_on_launch = false
  tags = {
    Project = "aws-poc"
  }
  provider = aws.sydney
}

resource "aws_subnet" "rds_prv_sub_2a" {
  vpc_id                  = aws_vpc.secondary.id
  cidr_block              = "172.17.14.0/24"
  availability_zone       = "ap-southeast-2a"
  map_public_ip_on_launch = false
  tags = {
    Project = "aws-poc"
  }
  provider = aws.sydney
}

resource "aws_route_table_association" "rt_assoc_2a" {
  subnet_id      = aws_subnet.pub_sub_2a.id
  route_table_id = aws_route_table.pub_rt_2.id
  provider       = aws.sydney
}

resource "aws_subnet" "pub_sub_2b" {
  vpc_id                  = aws_vpc.secondary.id
  cidr_block              = "172.17.21.0/24"
  availability_zone       = "ap-southeast-2b"
  map_public_ip_on_launch = true
  tags = {
    Project = "aws-poc"
  }
  provider = aws.sydney
}

resource "aws_subnet" "web_prv_sub_2b" {
  vpc_id                  = aws_vpc.secondary.id
  cidr_block              = "172.17.22.0/24"
  availability_zone       = "ap-southeast-2b"
  map_public_ip_on_launch = false
  tags = {
    Project = "aws-poc"
  }
  provider = aws.sydney
}

resource "aws_subnet" "app_prv_sub_2b" {
  vpc_id                  = aws_vpc.secondary.id
  cidr_block              = "172.17.23.0/24"
  availability_zone       = "ap-southeast-2b"
  map_public_ip_on_launch = false
  tags = {
    Project = "aws-poc"
  }
  provider = aws.sydney
}

resource "aws_subnet" "rds_prv_sub_2b" {
  vpc_id                  = aws_vpc.secondary.id
  cidr_block              = "172.17.24.0/24"
  availability_zone       = "ap-southeast-2b"
  map_public_ip_on_launch = false
  tags = {
    Project = "aws-poc"
  }
  provider = aws.sydney
}

resource "aws_route_table_association" "rt_assoc_2b" {
  subnet_id      = aws_subnet.pub_sub_2b.id
  route_table_id = aws_route_table.pub_rt_2.id
  provider       = aws.sydney
}
