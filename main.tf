terraform {
  cloud {
    # The name of your Terraform Cloud organization.
    organization = "sat-org"

    # The name of the Terraform Cloud workspace to store Terraform state files in.
    workspaces {
      name = "sat-workspace"
    }
  }
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

data "aws_ami" "amazon_ami" {
  # most_recent = true
  most_recent = false
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*20240722*-x86_64"]
  }
}

module "ccat-vpc" {
  source = "./modules/vpc"
}

resource "aws_iam_instance_profile" "ccat-s3-iam-role" {
  name = "ccat-s3-iam-role"
  role = "CCATEC2S3Role"
}

resource "aws_instance" "ccat-server" {
  ami                         = data.aws_ami.amazon_ami.id
  instance_type               = "t2.micro"
  count                       = 2
  subnet_id                   = module.ccat-vpc.ccat-public-subnet1-id
  key_name                    = "myec2key"
  associate_public_ip_address = true
  security_groups             = [module.ccat-vpc.ccat-public-sshgrp-id]
  tags = {
    "Name" = "ccat-server-${count.index}"
  }
  iam_instance_profile = aws_iam_instance_profile.ccat-s3-iam-role.name
  user_data            = <<EOT
#!/bin/bash
yum update -y
yum -y install java-17-amazon-corretto-headless
EOT
}

output "ccat_server_instance_ids" {
  value = [for server in aws_instance.ccat-server : server.public_ip]
}
