resource "aws_subnet" "subnet" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.availability_zone
  tags              = {
    Name : "${var.env_prefix}-subnet-1"
  }
}

resource "aws_internet_gateway" "internet-gw" {
  vpc_id = var.vpc_id
  tags   = {
    Name : "${var.env_prefix}-igw"
  }
}

resource "aws_default_route_table" "main-rtb" {
  default_route_table_id = var.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gw.id
  }

  tags = {
    Name : "${var.env_prefix}-main-rtb"
  }
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
