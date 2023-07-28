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

backend "s3" {
   bucket = "wellness-360-tfstate"
   key = "./terraform.tfstate"
   region = "us-west-2"
   dynamodb_table = "wellness-tfstate-table"
   encrypt = true
  }  
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

# DynamoDB table for Terraform state locking
resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "wellness-tfstate-table"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "wellness-tfstate-table"
    Environment = "dev"
  }
}

# S3 bucket resources
resource "aws_s3_bucket" "bucket" {
  count  = length(var.s3_bucket)
  bucket = element(var.s3_bucket,count.index)

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_acl" "Wellness-acl" {
  count  = length(var.s3_bucket)
  bucket = element(aws_s3_bucket.bucket.*.id,count.index)
  acl    = var.s3_acl

  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  count  = length(var.s3_bucket)
  bucket = element(aws_s3_bucket.bucket.*.id,count.index)

  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_versioning" "versioning_Wellness" {
  count  = length(var.s3_bucket)
  bucket = element(aws_s3_bucket.bucket.*.id,count.index)

  versioning_configuration {
    status = var.s3_bucket_versioning
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  count                    = length(var.s3_bucket)
  bucket                   = element(aws_s3_bucket.bucket.*.id,count.index)
  block_public_acls        = var.s3_bucket_block_acl
  block_public_policy      = var.s3_bucket_block_public_policy
  ignore_public_acls       = var.s3_bucket_block_public_acls
  restrict_public_buckets  = var.s3_bucket_restrict
}
