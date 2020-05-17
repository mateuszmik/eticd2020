provider "aws" {
  region     = var.region
  profile    = var.aws-profile
}

data "aws_subnet_ids" "private-subnets" {
  vpc_id = var.vpc-id

  tags = {
    Name = "*Private*"
  }
}

data "aws_vpc" "existing-vpc" {
  id = var.vpc-id
}

#==================================================

resource "aws_instance" "ec2s" {
  for_each      = data.aws_subnet_ids.private-subnets.ids
  tags = var.default_tags
  ami = var.ec2-ami
  instance_type = "t2.micro"
  subnet_id =  each.value
  key_name      = aws_key_pair.mm-sshkey.key_name
  vpc_security_group_ids = [aws_security_group.ec2-default-security-group.id]
}

resource "aws_key_pair" "mm-sshkey" {
  tags = var.default_tags
  key_name   = "mm-sshkey"
  public_key = "ssh-rsa *****************************8  YOUR PUBLIC KEY **********************8"
}


resource "aws_security_group" "ec2-default-security-group" {
  tags = var.default_tags
  name = "ec2-default-security-group"
  vpc_id = data.aws_vpc.existing-vpc.id
}

resource "aws_security_group_rule" "company-ip-addresses-inbound-ssh" {
  security_group_id = aws_security_group.ec2-default-security-group.id  
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["XXXXXXXXX"]   //YOUR IP RANGE
}

resource "aws_security_group_rule" "company-ip-addresses-outbound-all" {
  security_group_id = aws_security_group.ec2-default-security-group.id  
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = -1
  cidr_blocks = ["0.0.0.0/0"]
}


output "Machines_subnets" {
  value = {
    for instance in aws_instance.ec2s:
      instance.subnet_id => format("Private IP: %s (subnet %s)",instance.private_ip, instance.subnet_id)
  }
}

