# for public server
data "aws_ami" "windows" {
  most_recent = true
  owners      = ["amazon"] # Ensures official AMIs

  filter {
    name   = "name"
    values = ["Windows_Server-2025-English-Full-Base-*"]
  }
}

resource "aws_instance" "windows_bastion" {

  for_each = local.vpc_subnet_combination

  ami                         = data.aws_ami.windows.id
  instance_type               = "t3.large" # Windows needs a bit more memory than t3.micro
  associate_public_ip_address = true
  key_name                    = aws_key_pair.windows_key.key_name
  get_password_data           = true

  subnet_id = aws_subnet.public_subnet[each.key].id

  vpc_security_group_ids = [aws_security_group.bastion_sg[each.value.vpc_key].id]

  tags = {
    Name = "Windows-Bastion-test"
  }
}


# For private server

data "aws_ami" "amazon_linux" {
  most_recent = true       # this ensures that the most up-to-date version of the AMI is retreived
  owners      = ["amazon"] # ensure's officl AMI

  filter {
    name   = "name"                                #this wildcard pattern matches the heading for AMI for Amazin Lnexs AMI  
    values = ["al2023-ami-2023.*-kernel-*-x86_64"] #note that the '*' abstracts various changable numbers, like creation date and version number
  }
}

resource "aws_instance" "first7" {
  for_each = local.vpc_private_subnet_combination

  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  associate_public_ip_address = false
  key_name                    = aws_key_pair.windows_key.key_name

  subnet_id = aws_subnet.private_subnet[each.key].id
  # Links the instance to our security group
  vpc_security_group_ids = [aws_security_group.private_sg[each.value.vpc_key].id]

  tags = {
    Name = "Private Linux"
  }

  # On first boot, run a script to install our web server software.
  # the 'file' fucntion references the file path given, 'path.module' sets the path for the following '/<file>'
  # since ultimate file path for the user data now involves a map, you reference the particular script the the [each.ky], please reference the 
  user_data = file("${path.module}/${each.value.script}")

}