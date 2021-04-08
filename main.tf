#Here please input the credientials of your aws account
provider "aws" {
    #aws account IAM user's account access_key
    access_key = "${var.aws_access_key}"
    #aws account IAM user's account secret_key
    secret_key = "${var.aws_secret_key}"
    #aws account region
    region     =  "${var.aws_region}"
}


#Creating a aws_VPC 

resource "aws_vpc" "isonetwork" { 
  #we can create the cidr_block in any required region according to our wish 
  cidr_block = "10.0.0.0/16"
  #enabling dns_hostnames
  enable_dns_hostnames = true
  tags       = {
               Name = "${var.vpc_Name}"
               Env  = "Testing-vpc"
  }
}


# creating a aws_subnet
resource "aws_subnet" "two_tier_sub" {
  #count = length(var.CIDRS)  
  #name = "${element(var.Name,count.index)}"
  count = "${var.env == "prod" ? 2:1}"
  vpc_id     = "${aws_vpc.isonetwork.id}"
  cidr_block = "${element(var.CIDRS,count.index)}"
  #cidr_block = "10.1.1.0/24"
  #availability_zone ="${element(var.azs,count.index)}"
  availability_zone = "us-east-1a"
  tags = {
    Name = "${element(var.Name,count.index)}"

  }
}

#creating an aws_internet_gateway
resource "aws_internet_gateway" "testing_gateway" {
  vpc_id = "${aws_vpc.isonetwork.id}"

  tags = {
    Name = "${var.IGW_name}"
  }
}

#creating a aws_routetable
resource "aws_route_table" "routetesting" {
  vpc_id = "${aws_vpc.isonetwork.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.testing_gateway.id}"
  }

  tags = {
    Name = "${var.Main_Routing_Table}"
  }
}

#creating a aws_route_table_association
resource "aws_route_table_association" "routetesting_ass" { 
  count = "${length(aws_subnet.two_tier_sub)-1}"  
  subnet_id      = "${element(aws_subnet.two_tier_sub.*.id,count.index)}"
  route_table_id = "${aws_route_table.routetesting.id}"
  #subnet_id    = "${aws_subnet.testing_sub.id}"
}


#creating aws_security_group
resource "aws_security_group" "webSG" {
  name        = "webSG"
  description = "For Linux Web servers"
  vpc_id      = "${aws_vpc.isonetwork.id}"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ALL ICMP - IPv4"
    from_port   = 0
    to_port     = 0
    protocol    = "ICMP"
    cidr_blocks = ["10.0.0.0/16"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "WEB_SG"
  }
}

#creating aws_security_group
resource "aws_security_group" "BastionSG" {
  name        = "BastionSG"
  description = "For windows bastion host"
  vpc_id      = "${aws_vpc.isonetwork.id}"

  ingress {
    description = "RDP"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    description = "ALL ICMP -IPv4"
    from_port   = 0
    to_port     = 0
    protocol    = "ICMP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "BastionSG"
  }
}

#creaying aws_security_group
resource "aws_security_group" "DBSG" {
  name        = "DBSG"
  description = "For Linux db servers"
  vpc_id      = "${aws_vpc.isonetwork.id}"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
   ingress {
    description = "MYSQL/AURORA"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
   ingress {
    description = "ALL ICMP -IPv4"
    from_port   = 0
    to_port     = 0
    protocol    = "ICMP"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DBSG"
  }
}
