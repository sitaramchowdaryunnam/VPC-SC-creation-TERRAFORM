Now task is to create an isolated network for our project. That thing can be done with VPC service.

In three tier architecture there is one web server and one database server. As per the requirement we need 2 networks in a single VPC. create 2 different subets

Webserver – 10.0.1.0/24
Database – 10.0..2.0/24
Subnet where you are going to configure your web server will be connected to the internet and another where you have DB server should not connected to the internet. You will also need a bastion server to connect your private VM’s.

You will need an Internet Gateway to communicate outside your VPC, also a route table which will route traffic outside the VPC using Internet Gateway.

Create 03 security group for

1)web Server,
2)DB Server and
3)Bastion Host.

And manage inbound traffic for security.

Through terraform we had deployed this task.
