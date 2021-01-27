data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_ami" "redhat_linux" {
  owners = ["309956199498"]

  filter {
    name = "name"

    values = [
      "RHEL-7.7_HVM_GA-20190723-x86_64-1-Hourly2-GP2",
    ]
  }
}

module "security_group" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "~> 3.0"

  name        = "${var.vm_prefix}-satellite-security"
  description = "Security group for satellite usage with EC2 instance"
  vpc_id      = data.aws_vpc.default.id

  ingress_with_cidr_blocks    = [
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
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "All traffic"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  ingress_with_ipv6_cidr_blocks   = [
    {
      from_port        = 30000
      to_port          = 32767
      protocol         = "udp"
      ipv6_cidr_blocks = "::/0"
    },
    {
      from_port        = 30000
      to_port          = 32767
      protocol         = "tcp"
      ipv6_cidr_blocks = "::/0"
    },
    {
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      description      = "HTTPS TCP"
      ipv6_cidr_blocks = "::/0"
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

  egress_with_ipv6_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "All traffic - ipv6"
      ipv6_cidr_blocks = "::/0"
    },
  ]

}

resource "aws_placement_group" "web" {
  name     = "${var.vm_prefix}-hunky-dory-pg"
  strategy = "cluster"
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "keypair" {
  key_name    = "${var.vm_prefix}-ssh"
  public_key  = var.ssh_public_key != "" ? var.ssh_public_key : tls_private_key.example.public_key_openssh
}


module "ec2" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  
  depends_on                  = [ module.satellite-location ]
  instance_count              = var.satellite_host_count + var.addl_host_count
  name                        = "${var.vm_prefix}-host"
  use_num_suffix              = true
  ami                         = data.aws_ami.redhat_linux.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.keypair.key_name
  subnet_id                   = tolist(data.aws_subnet_ids.all.ids)[0]
  vpc_security_group_ids      = [module.security_group.this_security_group_id]
  associate_public_ip_address = true
  placement_group             = aws_placement_group.web.id
  user_data                   = file(replace("${path.module}/addhost.sh*${module.satellite-location.module_id}", "/[*].*/", ""))

}