
#creating aws_instance
resource "aws_instance" "devops_test" {
  count = "${length(aws_subnet.testing_sub)}"  
  ami           =  "${var.aws_ami}"
  instance_type = "t2.micro"
  availability_zone = "${element(var.azs,count.index)}"
  #availability_zone = "us-east-1a"
  key_name = "laptopkey"
  subnet_id = "${element(aws_subnet.testing_sub.*.id,count.index)}"
  #subnet_id = "${aws_subnet.testing_sub.id}"
  vpc_security_group_ids = ["${aws_security_group.allow_tls.id}"]
  associate_public_ip_address = true	
  tags = {
    Name = "HelloWorld"
    env = "prod"
  }
 
}
resource "null_resource" "dockerinstall"{
     depends_on = ["aws_instance.devops_test"]
    count = "${length(aws_subnet.testing_sub)}" 
     provisioner "remote-exec"{
         connection{
          type = "ssh"
          user = "ec2-user"
          private_key = "${file("C:/Users/sitar/Downloads/laptopkey.pem")}"
          host = "${element(aws_instance.devops_test.*.public_ip,count.index)}"
          #host  = "${aws_instance.devops_test.public_ip}"
      }
      inline = [

          "sudo yum update -y",
          " sudo amazon-linux-extras install nginx1 -y",
          "sudo systemctl start nginx",
          "sudo yum update -y",
          "sudo amazon-linux-extras install docker -y",
          "sudo yum install docker -y",
          "sudo service docker start ",
          "sudo usermod -aG docker ec2-user",
          "sudo docker info"

      ]
  }
  #depends_on = [aws_instance.devops_test]
}