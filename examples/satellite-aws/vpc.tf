
# Declare the data source
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.resource_prefix}-vpc"
  cidr = "10.0.0.0/16"

  azs             = length(var.location_zones) == 0 ? local.azs : var.location_zones
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  enable_ipv6     = true

  enable_nat_gateway = false
  single_nat_gateway = true

  public_subnet_tags = {
    Name = var.resource_prefix
  }

  tags = {
    ibm-satellite = var.resource_prefix
  }

  vpc_tags = {
    Name = var.resource_prefix
  }
}



