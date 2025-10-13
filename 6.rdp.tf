# before running `terraoform plan`, you must first create the key pairs and the rdp 
resource "local_file" "rdp_file" {
  for_each = local.vpc_subnet_combination
  # The content of the .rdp file
  content = <<-EOF
    auto connect:i:1
    full address:s:${aws_instance.windows_bastion[each.key].public_ip}
    username:s:Administrator
  EOF

  # The name of the file that will be created
  filename = "${path.module}/windows-bastion.rdp"
}

