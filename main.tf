provider "aws" {
  region = "us-east-2"
}

variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "availability_zone" {}
variable "env_prefix" {}
variable "my_ip" {}
variable "ec2_instance_type" {}
variable "ssh_key_path" {}

resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags       = {
    Name : "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "myapp-subnet-1" {
  vpc_id            = aws_vpc.myapp-vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.availability_zone
  tags              = {
    Name : "${var.env_prefix}-subnet-1"
  }
}

resource "aws_internet_gateway" "myapp-internet-gw" {
  vpc_id = aws_vpc.myapp-vpc.id
  tags   = {
    Name : "${var.env_prefix}-igw"
  }
}

resource "aws_default_route_table" "main-rtb" {
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-internet-gw.id
  }

  tags = {
    Name : "${var.env_prefix}-main-rtb"
  }
}

resource "aws_security_group" "myapp-sg" {
  name   = "myapp-sg"
  vpc_id = aws_vpc.myapp-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name : "${var.env_prefix}-sg"
  }
}

data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "terraform-key-2"
  public_key = file(var.ssh_key_path)
}

resource "aws_instance" "myapp-server" {
  ami           = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.ec2_instance_type

  subnet_id              = aws_subnet.myapp-subnet-1.id
  security_groups        = [aws_security_group.myapp-sg.id]
  vpc_security_group_ids = [aws_security_group.myapp-sg.id]
  availability_zone      = var.availability_zone

  associate_public_ip_address = true

  key_name = aws_key_pair.ssh-key.key_name
  
  user_data = file("./shell/init-server.sh")

  tags = {
    Name : "${var.env_prefix}-myapp-server"
  }
}

output "aws-ami-id" {
  value = data.aws_ami.latest-amazon-linux-image.id
}

output "ec2-public-ip" {
  value = aws_instance.myapp-server.public_ip
}

#create route table and associate it with subnet
#resource "aws_route_table" "myapp-route-table" {
#  vpc_id = aws_vpc.myapp-vpc.id
#
#  route {
#    cidr_block = "0.0.0.0/0"
#    gateway_id = aws_internet_gateway.myapp-internet-gw.id
#  }
#
#  tags = {
#    Name: "${var.env_prefix}-rtb"
#  }
#}
#
#resource "aws_route_table_association" "myapp-rtb-a" {
#  route_table_id = aws_route_table.myapp-route-table.id
#  subnet_id = aws_subnet.myapp-subnet-1.id
#}
