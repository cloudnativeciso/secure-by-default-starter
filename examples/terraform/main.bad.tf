#############################################
# INTENTIONALLY INSECURE – TRAINING EXAMPLE
# DO NOT COPY TO PRODUCTION
#
# Demonstrates common anti-patterns that scanners flag:
# - Public ingress on SSH/RDP/All TCP from 0.0.0.0/0
# - Public egress (0.0.0.0/0 and ::/0)
# - Public S3 bucket (ACL), public access block disabled
# - No encryption / versioning on S3
# - Missing tags/ownership metadata
#############################################

terraform {
  required_version = "~> 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"
}

# Wide-open Security Group (BAD)
resource "aws_security_group" "insecure_sg" {
  name        = "insecure-sg"
  description = "Open SG for demo (INSECURE)"
  vpc_id      = "vpc-12345678" # demo placeholder

  # SSH from anywhere (BAD)
  ingress {
    description = "SSH from Internet (BAD)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # RDP from anywhere (BAD)
  ingress {
    description = "RDP from Internet (BAD)"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Any TCP from anywhere (BAD)
  ingress {
    description = "Any TCP (BAD)"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress anywhere (BAD)
  egress {
    description = "All egress (BAD)"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # No tags on purpose (BAD)
}

# Public S3 bucket with public access block disabled (BAD)
resource "aws_s3_bucket" "insecure_bucket" {
  bucket        = "cnciso-insecure-demo-${random_id.suffix.hex}"
  force_destroy = true # allows accidental data loss (BAD)
  # No server-side encryption block (BAD)
  # No versioning (BAD)
  # Public ACL (BAD)
  acl = "public-read"
}

resource "aws_s3_bucket_public_access_block" "insecure_bucket_pab" {
  bucket                  = aws_s3_bucket.insecure_bucket.id
  block_public_acls       = false  # BAD
  block_public_policy     = false  # BAD
  ignore_public_acls      = false  # BAD
  restrict_public_buckets = false  # BAD
}

# Random suffix so plans don't collide (demo only)
resource "random_id" "suffix" {
  byte_length = 2
}
