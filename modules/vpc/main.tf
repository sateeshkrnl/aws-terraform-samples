data "aws_availability_zones" "available" {}

resource "aws_vpc" "ccat-vpc" {
  cidr_block = "120.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    "Name":"ccat-vpc"
  }     
}

resource "aws_internet_gateway" "ccat-igw" {
  vpc_id = aws_vpc.ccat-vpc.id
  tags = {
    "Name" = "ccat-igw" 
  }
}

resource "aws_subnet" "ccat-public-subnet1" {
  vpc_id = aws_vpc.ccat-vpc.id
  cidr_block = "120.0.1.0/24"
  tags = {
    "Name" = "ccat-public-subnet1" 
  }
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_route_table" "ccat-public-route" {
  vpc_id = aws_vpc.ccat-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ccat-igw.id
  }

  route {
    cidr_block = "120.0.0.0/16"
    gateway_id = "local"
  }
  
  tags = {
    "Name" = "ccat-public-route"
  }
}

resource "aws_route_table_association" "ccat-public-route-table-assoc" {
  route_table_id = aws_route_table.ccat-public-route.id
  subnet_id = aws_subnet.ccat-public-subnet1.id
}

resource "aws_security_group" "ccat-public-sshgroup" {
  vpc_id = aws_vpc.ccat-vpc.id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "TCP"
    to_port = "22"
    from_port = "22"    
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "TCP"
    from_port = "0"
    to_port = "65535"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "TCP"
    from_port = "0"
    to_port = "65535"
  }
  name = "ccat-public-sshgroup"
}

output "ccat-vpc-id" {
  description = "CCAT vpc id"
  value = aws_vpc.ccat-vpc.id
}

output "ccat-public-subnet1-id" {
  description = "ccat public subnet id"
  value = aws_subnet.ccat-public-subnet1.id
}

output "ccat-public-sshgrp-id" {
  value = aws_security_group.ccat-public-sshgroup.id
}