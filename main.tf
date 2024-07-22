terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.30.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-2"
}

data "aws_availability_zones" "available" {}

# module "ccat-vpc" {
#   source = "terraform-aws-modules/vpc/aws"
#   name   = "ccat-vpc"
#   cidr   = "170.0.0.0/16"
#   create_igw = true
#   azs = data.aws_availability_zones.available.names
#   # private_subnets = ["170.0.1.0/24","170.0.2.0/24"]
#   # private_subnet_names = ["ccat-private-subnet1","ccat-private-subnet2"]
#   public_subnet_names = ["ccat-public-subnet1"]
#   public_subnets = ["170.0.3.0/24"]
# }

# module "ccat-webserver" {
#   source = "terraform-aws-modules/ec2-instance/aws"
#   ami = "ami-0649bea3443ede307"
#   name = "ccat-webserver"
#   instance_type = "t2.micro"
#   subnet_id = module.ccat-vpc.public_subnets[0]
#   key_name = "myec2key"
# }

# resource "aws_route_table" "public_route_table" {
#   vpc_id = module.ccat-vpc.vpc_id
#   route {
#     cidr_block = module.ccat-vpc.vpc_cidr_block
#     gateway_id = "local"
#   }
#   route {
#     cidr_block = "20.0.0.0/16"
#     gateway_id = module.ccat-vpc.igw_id
#   }
# }
module "ccat-vpc" {
  source = "./modules/vpc"
}

resource "aws_instance" "ccat-server" {
  ami                         = "ami-0649bea3443ede307"
  instance_type               = "t2.micro"
  count = 2
  subnet_id                   = module.ccat-vpc.ccat-public-subnet1-id
  key_name                    = "myec2key"
  associate_public_ip_address = true
  security_groups             = [module.ccat-vpc.ccat-public-sshgrp-id]
  tags = {
    "Name" = "ccat-server-${count.index}"
  }
}