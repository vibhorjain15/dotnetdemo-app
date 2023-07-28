terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.20.1"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
    
resource "aws_key_pair" "kp" {
  key_name   = "test-Key"       # Create a "wellness-Key" to AWS!!
  public_key = tls_private_key.pk.public_key_openssh
}
    
resource "local_file" "tf-key" {
  content  = tls_private_key.pk.private_key_pem
  filename = "test-key-pair"
}

resource "aws_instance" "windows_instance" {
  ami           = "ami-072ec8f4ea4a6f2cf"  # Replace with the Windows Server AMI ID in your region
  instance_type = "t2.micro"  # Adjust instance type based on your requirements
  key_name      = aws_key_pair.kp.key_name
  # Networking settings
  # vpc_security_group_ids = [aws_security_group.instance.id]
  subnet_id              = "subnet-0d2bf24afefe0a18f"

  # User data script to install Docker Desktop and other configurations on the instance
  user_data = <<-EOF
#!/bin/bash

set -xe

sudo yum install docker -y
sudo systemctl enable docker --now

EOF
}
