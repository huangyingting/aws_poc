resource "aws_vpc" "primary" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Project = "aws-poc"
  }
}

resource "aws_internet_gateway" "primary" {
  vpc_id = aws_vpc.primary.id
  tags = {
    Project = "aws-poc"
  }
}

resource "aws_subnet" "pub_sub_1a" {
  vpc_id                  = aws_vpc.primary.id
  cidr_block              = "172.16.11.0/24"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = true
  tags = {
    Project = "aws-poc"
  }
}

resource "aws_subnet" "web_prv_sub_1a" {
  vpc_id                  = aws_vpc.primary.id
  cidr_block              = "172.16.12.0/24"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = false
  tags = {
    Project = "aws-poc"
  }
}

resource "aws_subnet" "app_prv_sub_1a" {
  vpc_id                  = aws_vpc.primary.id
  cidr_block              = "172.16.13.0/24"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = false
  tags = {
    Project = "aws-poc"
  }
}

resource "aws_subnet" "rds_prv_sub_1a" {
  vpc_id                  = aws_vpc.primary.id
  cidr_block              = "172.16.14.0/24"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = false
  tags = {
    Project = "aws-poc"
  }
}

resource "aws_eip" "nat_eip_1a" {
  vpc = true
  tags = {
    Project = "aws-poc"
  }
}

resource "aws_nat_gateway" "ngw_1a" {
  allocation_id = aws_eip.nat_eip_1a.id
  subnet_id     = aws_subnet.pub_sub_1a.id
  tags = {
    Project = "aws-poc"
  }
}

resource "aws_route_table" "prv_rt_1a" {
  vpc_id = aws_vpc.primary.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw_1a.id
  }
  tags = {
    Project = "aws-poc"
  }
}

resource "aws_subnet" "pub_sub_1b" {
  vpc_id                  = aws_vpc.primary.id
  cidr_block              = "172.16.21.0/24"
  availability_zone       = "ap-southeast-1b"
  map_public_ip_on_launch = true

  tags = {
    Project = "aws-poc"
  }
}

resource "aws_subnet" "web_prv_sub_1b" {
  vpc_id                  = aws_vpc.primary.id
  cidr_block              = "172.16.22.0/24"
  availability_zone       = "ap-southeast-1b"
  map_public_ip_on_launch = false

  tags = {
    Project = "aws-poc"
  }
}

resource "aws_subnet" "app_prv_sub_1b" {
  vpc_id                  = aws_vpc.primary.id
  cidr_block              = "172.16.23.0/24"
  availability_zone       = "ap-southeast-1b"
  map_public_ip_on_launch = false

  tags = {
    Project = "aws-poc"
  }
}

resource "aws_subnet" "rds_prv_sub_1b" {
  vpc_id                  = aws_vpc.primary.id
  cidr_block              = "172.16.24.0/24"
  availability_zone       = "ap-southeast-1b"
  map_public_ip_on_launch = false

  tags = {
    Project = "aws-poc"
  }
}


resource "aws_route_table" "pub_rt_1" {
  vpc_id = aws_vpc.primary.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.primary.id
  }
  tags = {
    Project = "aws-poc"
  }
}

resource "aws_route_table_association" "rt_assoc_1a" {
  subnet_id      = aws_subnet.pub_sub_1a.id
  route_table_id = aws_route_table.pub_rt_1.id
}

resource "aws_route_table_association" "web_prv_1a_rt_assoc" {
  subnet_id      = aws_subnet.web_prv_sub_1a.id
  route_table_id = aws_route_table.prv_rt_1a.id
}

resource "aws_route_table_association" "app_prv_1a_rt_assoc" {
  subnet_id      = aws_subnet.app_prv_sub_1a.id
  route_table_id = aws_route_table.prv_rt_1a.id
}


resource "aws_route_table_association" "rt_assoc_1b" {
  subnet_id      = aws_subnet.pub_sub_1b.id
  route_table_id = aws_route_table.pub_rt_1.id
}

resource "aws_route_table_association" "web_prv_1b_rt_assoc" {
  subnet_id      = aws_subnet.web_prv_sub_1b.id
  route_table_id = aws_route_table.prv_rt_1a.id
}

resource "aws_route_table_association" "app_prv_1b_rt_assoc" {
  subnet_id      = aws_subnet.app_prv_sub_1b.id
  route_table_id = aws_route_table.prv_rt_1a.id
}
