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

resource "aws_vpc" "testing" { 
  #we can create the cidr_block in any required region according to our wish 
  cidr_block = "10.1.0.0/16"
  #enabling dns_hostnames
  enable_dns_hostnames = true
  tags       = {
               Name = "${var.vpc_Name}"
               Env  = "Prod test"
  }
}


# creating a aws_subnet
resource "aws_subnet" "testing_sub" {
  #count = length(var.CIDRS)  
  count = "${var.env == "prod" ? 3:1}"
  vpc_id     = "${aws_vpc.testing.id}"
  cidr_block = "${element(var.CIDRS,count.index)}"
  #cidr_block = "10.1.1.0/24"
  availability_zone ="${element(var.azs,count.index)}"
  #availability_zone = "us-east-1a"
  tags = {
    Name = "Subnet-1"

  }
}

#creating a aws_internet_gateway
resource "aws_internet_gateway" "testing_gateway" {
  vpc_id = "${aws_vpc.testing.id}"

  tags = {
    Name = "${var.IGW_name}"
  }
}

#creating a aws_routetable
resource "aws_route_table" "routetesting" {
  vpc_id = "${aws_vpc.testing.id}"

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
  count = "${length(aws_subnet.testing_sub)}"  
  subnet_id      = "${element(aws_subnet.testing_sub.*.id,count.index)}"
  route_table_id = "${aws_route_table.routetesting.id}"
  #subnet_id    = "${aws_subnet.testing_sub.id}"
}


#creaying aws_security_group
resource "aws_security_group" "allow_tls" {
  name        = "Allow_all"
  description = "Allow TLS inbound traffic"
  vpc_id      = "${aws_vpc.testing.id}"

  ingress {
    description = "TLS from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}
