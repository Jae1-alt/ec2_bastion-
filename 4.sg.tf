
resource "aws_security_group" "bastion_sg" {
  for_each = aws_vpc.main

  name        = "bastion-sg-${each.key}"
  description = "Allow SSH from my IP"
  vpc_id      = aws_vpc.main[each.key].id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}"]
  }

  ingress {
    description = "RDP from my IP"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip_rdp}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allows all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private_sg" {
  for_each = aws_vpc.main

  name        = "private-server-sg-${each.key}"
  description = "Allow traffic only from the bastion host"
  vpc_id      = aws_vpc.main[each.key].id

  ingress {
    description = "Allow SSH from the Bastion Security Group"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    security_groups = [aws_security_group.bastion_sg[each.key].id]
  }

  ingress {
    description     = "Allow HTTP from the Bastion Security Group"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg[each.key].id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
