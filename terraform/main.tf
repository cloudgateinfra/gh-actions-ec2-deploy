#### WARNING BACKEND STATE USAGE ####
# if new pipeline/repo on github, replace "key"
# in backend s3 resource with a new path
# otherwise this will overwrite other state files with same path key
# in that s3 bucket when starting new pipelines

provider "aws" {
  region = "us-west-2"
}

terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket      = "tf-dev-remote-state-github-piplines"
    key         = "auto-provision-pr-pipe/terraform.tfstate"
    region      = "us-west-2"
    encrypt     = true
  }
}

# VPC and subnets
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security group
data "aws_security_group" "default" {
  id = var.sg
}

# EC2 instance
resource "aws_instance" "web" {
  ami                      = var.ami
  instance_type            = var.hardware
  security_groups          = [data.aws_security_group.default.name]
  user_data                = "${file("test.sh")}"
  key_name                 = "testpipe1"
  tags = {
    Name = var.domain
    test_env = "true"
  }
}

# Elastic IP
resource "aws_eip" "eip" {
  instance = aws_instance.web.id
  vpc      = true
  tags = {
    Name = var.domain
    test_env = "true"
  }
}

# Route53 record // needed for subdomain creation for prod/stage; for now dev sandbox whitelist IPs auto with SSO IT setup
#resource "aws_route53_record" "record" {
#  zone_id  = var.zone
#  name     = var.domain
#  type     = "A"
#  ttl      = 300
#  records  = [aws_eip.eip.public_ip]
#}
