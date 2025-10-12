resource "aws_vpc" "main" {
  for_each = var.vpc_info

  # work in progress
  # provider = {
  #   "us-east-1" = aws.us-east-1,
  #   "us-west-1" = aws.us-west-1
  # }[each.value.vpc_region]

  region     = each.value.vpc_region
  cidr_block = each.value.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = local.vpc_tags[each.key]

}

data "aws_availability_zones" "available" {
  for_each = local.vpc_subnet_combination

  state  = "available"
  region = each.value.vpc_region
}

data "aws_availability_zones" "available1" {
  for_each = local.vpc_private_subnet_combination

  state  = "available"
  region = each.value.vpc_region
}

resource "aws_subnet" "public_subnet" {
  for_each = local.vpc_subnet_combination

  vpc_id            = aws_vpc.main[each.value.vpc_key].id
  cidr_block        = each.value.subnet_cidr
  availability_zone = data.aws_availability_zones.available[each.key].names[0]

  map_public_ip_on_launch = true

  tags = {
    Name = "test-public"
  }
}

resource "aws_subnet" "private_subnet" {
  for_each = local.vpc_private_subnet_combination

  vpc_id            = aws_vpc.main[each.value.vpc_key].id
  cidr_block        = each.value.subnet_cidr
  availability_zone = data.aws_availability_zones.available1[each.key].names[0]

  tags = {
    Name = "test-private"
  }
}