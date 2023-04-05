provider "aws" {
  region = "us-east-2"
}

resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags       = {
    Name : "${var.env_prefix}-vpc"
  }
}

module "myapp-subnet" {
  source = "./modules/subnet"
  vpc_id                 = aws_vpc.myapp-vpc.id
  availability_zone      = var.availability_zone
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
  env_prefix             = var.env_prefix
  subnet_cidr_block      = var.subnet_cidr_block
}

module "myapp-webserver" {
  source = "./modules/webserver"
  ami_name = var.ami_name
  availability_zone = var.availability_zone
  ec2_instance_type = var.ec2_instance_type
  env_prefix = var.env_prefix
  my_ip = var.my_ip
  ssh_key_path = var.ssh_key_path
  subnet_id = module.myapp-subnet.subnet.id
  vpc_id = aws_vpc.myapp-vpc.id
}
