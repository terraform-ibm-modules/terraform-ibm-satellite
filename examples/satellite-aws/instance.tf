
data "aws_ami" "redhat_linux" {
  owners = ["309956199498"]

  filter {
    name = "name"

    values = [
      var.aws_ami,
    ]
  }
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "${var.resource_prefix}-sg"
  description = "Security group for satellite usage with EC2 instance"
  vpc_id      = module.vpc.vpc_id

  tags = {
    ibm-satellite = var.resource_prefix
  }

  ingress_with_cidr_blocks = [
    {
      from_port   = 30000
      to_port     = 32767
      protocol    = "udp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 30000
      to_port     = 32767
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS TCP"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP TCP"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "All traffic"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  ingress_with_self = [
    {
      from_port = 0
      to_port   = 0
      protocol  = -1
      self      = true
    },
  ]

}

resource "aws_placement_group" "satellite-group" {
  for_each = var.hosts
  name     = "${var.resource_prefix}-pg-${each.key}"
  strategy = "spread"

  tags = {
    ibm-satellite = var.resource_prefix
  }

}
#####################################################
# IBM Cloud Satellite -  AWS Example
# Copyright 2021 IBM
#####################################################

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "keypair" {
  for_each   = var.hosts
  depends_on = [module.satellite-location]

  key_name   = "${var.resource_prefix}-ssh-${each.key}"
  public_key = var.ssh_public_key != null ? var.ssh_public_key : tls_private_key.example.public_key_openssh

  tags = {
    ibm-satellite = var.resource_prefix
  }

}


module "ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.21.0"

  for_each = var.hosts

  depends_on                  = [module.satellite-location]
  instance_count              = each.value.count
  name                        = "${var.resource_prefix}-host-${each.key}"
  use_num_suffix              = true
  ami                         = data.aws_ami.redhat_linux.id
  instance_type               = each.value.instance_type
  key_name                    = aws_key_pair.keypair[each.key].key_name
  subnet_ids                  = module.vpc.public_subnets
  vpc_security_group_ids      = [module.security_group.this_security_group_id]
  associate_public_ip_address = true
  placement_group             = aws_placement_group.satellite-group[each.key].id
  user_data                   = module.satellite-location.host_script

  tags = {
    ibm-satellite = var.resource_prefix
  }
}
