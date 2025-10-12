
output "private_linux_ip" {
  description = "ip address for private instance"
  value = {
    for key, instance in aws_instance.first7 : key => instance.private_ip
  }
}

output "windows_password_encrypted" {
  description = "Password for rdp"
  value = {
    for key, instance in aws_instance.windows_bastion : key => instance.password_data
  }
  sensitive = true
}