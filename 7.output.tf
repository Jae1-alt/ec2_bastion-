
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

output "windows_password" {
  description = "Password for rdp"
  value = {
    for key, instance in aws_instance.windows_bastion : key => nonsensitive(rsadecrypt(instance.password_data, tls_private_key.rsa.private_key_pem))
  }
}