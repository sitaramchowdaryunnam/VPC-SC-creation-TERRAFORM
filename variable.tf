variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}
variable "vpc_Name" {}
variable "IGW_name" {}
variable "Main_Routing_Table" {}
variable "public_subnet"{}
variable "subnet_name"{}
 variable "CIDRS"{
     description ="CIDR Blocks for subnet"
     type = "list"
     default = ["10.1.1.0/24","10.1.2.0/24","10.1.3.0/24"]
    }
  variable "azs"{
     description ="Runs az in this xones"
     type = "list"
     default = ["us-east-1a","us-east-1b","us-east-1c"]
    } 
#  variable "ami"{}
 variable "env"{}
 variable "aws_key_name"{}
 variable "aws_ami" {}
#  variable "private_key"{}