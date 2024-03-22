
resource "aws_key_pair" "ec2_pub_key"{
  key_name = "ec2_pub_key"
  public_key = file("${path.module}/../keys/ec2_key.pub")
}

resource "aws_instance" "jenkins-master" {
  ami = "${var.ami["debian"]}"
  instance_type = "t2.micro"
  key_name = aws_key_pair.ec2_pub_key.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_incoming_access.id, aws_security_group.jenkins_outgoing_access.id]

  tags = {
    Name = "jenkins-example"
  }
}

resource "aws_security_group" "jenkins_incoming_access" {
  name        = "jenkins_incoming_access"
  description = "Allow inbound SSH traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from any IP address (make sure to restrict this in production)
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "jenkins_outgoing_access" {
  name        = "jenkins_outgoing_access"
  description = "Security group for EC2 instance"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow outbound traffic to all destinations (0.0.0.0/0) on all ports and protocols
  }
}

output "ec2_instance_hostname" {
  value = aws_instance.jenkins-master.public_dns
}

output "ec2_instance_ip" {
  value = aws_instance.jenkins-master.public_ip
}

output "jenkins_sec_grp"{
  value = aws_security_group.jenkins_outgoing_access.id
}