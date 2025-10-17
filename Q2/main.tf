# Data sources
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Key pair
resource "aws_key_pair" "webserver_key" {
  key_name   = var.key_name
  public_key = file("~/.ssh/web_server.pub")
}

# Security group
resource "aws_security_group" "webserver_sg" {
  name        = "webserver-security-group"
  description = "Security group for web server"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "webserver-sg"
  }
}

# User data script
locals {
  user_data = base64encode(templatefile("${path.module}/user-data.sh", {}))
}

# EC2 instance
resource "aws_instance" "webserver" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name              = aws_key_pair.webserver_key.key_name
  vpc_security_group_ids = [aws_security_group.webserver_sg.id]
  user_data_base64      = local.user_data

  tags = {
    Name = "webserver-instance"
  }
}