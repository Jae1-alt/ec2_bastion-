
resource "aws_eip" "nat" {
  # This will create one EIP for each VPC.
  for_each = aws_vpc.main

  tags = {
    Name = "${each.key}-nat-eip"
  }
}

resource "aws_nat_gateway" "example" {
  for_each = aws_vpc.main

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = values(aws_subnet.public_subnet)[0].id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}