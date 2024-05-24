//creating a VPC
resource "aws_vpc" "wordpress-vpc" {
  tags = merge(var.tags, {
    Name        = "wordpress-vpc"
    Environment = "production"
    Company     = "Clevertap"
  })
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
}

