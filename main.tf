terraform {
  required_version = ">=0.13"
  backend "s3" {
    bucket = "salesflowio-terraform-state"
    key = "myapp/state.tfstate"
    region = "us-east-2"
  }
}
provider "aws" {
  region = "us-east-2"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  name = "my-vpc"
  cidr = var.vpc_cidr_block

  azs                = [var.availability_zone]
  public_subnets     = [var.subnet_cidr_block]
  public_subnet_tags = {
    Name = "${var.env_prefix}-subnet-1"
  }

  tags = {
    Name = "${var.env_prefix}-vpc"
    Terraform   = "true"
    Environment = "dev"
  }
}

module "myapp-webserver" {
  source            = "./modules/webserver"
  ami_name          = var.ami_name
  availability_zone = var.availability_zone
  ec2_instance_type = var.ec2_instance_type
  env_prefix        = var.env_prefix
  my_ip             = var.my_ip
  ssh_key_path      = var.ssh_key_path
  subnet_id         = module.vpc.public_subnets[0]
  vpc_id            = module.vpc.vpc_id
}
