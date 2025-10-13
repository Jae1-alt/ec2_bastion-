# some more variable customization to be done

resource "aws_internet_gateway" "igw" {
  for_each = aws_vpc.main

  vpc_id = aws_vpc.main[each.key].id

  tags = local.igw_tags[each.key]
}

# public traffic routing 
resource "aws_route_table" "public_rt" {
  for_each = aws_vpc.main

  vpc_id = aws_vpc.main[each.key].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw[each.key].id
  }

  tags = {
    Name = "${each.key}-public-rt"
  }
}

resource "aws_route_table_association" "public_subnet_assoc" {
  for_each = local.vpc_subnet_combination

  subnet_id      = aws_subnet.public_subnet[each.key].id
  route_table_id = aws_route_table.public_rt[each.value.vpc_key].id
}


# private traffic routing, note that routes for local traffic are automatically created for created route tables.
resource "aws_route_table" "private_rt" {
  for_each = aws_vpc.main

  vpc_id = aws_vpc.main[each.key].id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.example[each.key].id
  }

  tags = {
    Name = "${each.key}-private-rt"
  }
}

resource "aws_route_table_association" "private_subnet_assoc" {
  for_each = local.vpc_private_subnet_combination

  subnet_id      = aws_subnet.private_subnet[each.key].id
  route_table_id = aws_route_table.private_rt[each.value.vpc_key].id
}