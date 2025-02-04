terraform {
  required_version = ">= 1.10.5"
  
  required_providers {
    aws = ">= 3.54.0"
    local = ">= 2.1.0"
  }

  backend "s3" {
    bucket = "wkfcbucket"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

provider "aws" {
  region = "us-east-1"
}

module "new-vpc" {
  source        = "./modules/vpc"
  prefix        = var.prefix
  vpc_cidr_block = var.vpc_cidr_block
}

module "ec2" {
  source        = "./modules/ec2"
  ami_id        = data.aws_ami.latest_amazon_linux.id
  instance_type = var.instance_type
  instance_name = var.instance_name
  region        = var.region
  vpc_id        = module.new-vpc.vpc_id
  prefix        = var.prefix
  subnet_ids    = module.new-vpc.subnet_ids
}