provider "aws" {
  region = "us-east-2"
}

variable "cidr_blocks" {
  description = "cidr blocks and name tags for vpc and subnets"
  type = list(object({
    cidr_block = string
    name = string
  }))
}

variable ENV_AVAIL_ZONE {}

resource "aws_vpc" "tr-vpc" {
  cidr_block = var.cidr_blocks[0].cidr_block
  tags = { 
    Name: var.cidr_blocks[0].name
  }
}

resource "aws_subnet" "tr-subnet-1" {
  vpc_id = aws_vpc.tr-vpc.id
  cidr_block = var.cidr_blocks[1].cidr_block
  availability_zone = var.ENV_AVAIL_ZONE
  tags = {
    Name: var.cidr_blocks[1].name
  }
}

data "aws_vpc" "default-vpc" {
  default = true
}

output "tr-vpc-id" {
  value = aws_vpc.tr-vpc.id
}
output "tr-subnet-1-id" {
  value = aws_subnet.tr-subnet-1.id
}
output "tr-subnet-1-arn" {
  value = aws_subnet.tr-subnet-1.arn
}
