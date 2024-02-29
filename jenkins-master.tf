provider "aws" {
  region = "eu-central-1"
}

resource "aws_key_pair" "ec2_pub_key"{
  key_name = "ec2_pub_key"
  public_key = file("${path.module}/keys/ec2_key.pub")
}

resource "aws_instance" "jenkins-master" {
  ami = "ami-042e6fdb154c830c5"
  instance_type = "t2.micro"
  key_name = aws_key_pair.ec2_pub_key.key_name
  vpc_security_group_ids = [aws_security_group.ssh_access.id]

  tags = {
    Name = "jenkins-example"
  }
}

resource "aws_security_group" "ssh_access" {
  name        = "allow-ssh"
  description = "Allow inbound SSH traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from any IP address (make sure to restrict this in production)
  }
}

output "ec2_instance_hostname" {
  value = aws_instance.jenkins-master.public_dns
}

output "ec2_instance_ip" {
  value = aws_instance.jenkins-master.public_ip
}