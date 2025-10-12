# generate private key

resource "aws_key_pair" "windows_key" {
  key_name   = "windows-key"
  public_key = tls_private_key.rsa.public_key_openssh # Point this to your public from the tls_private.rsaresource
}

# resource "aws_key_pair" "linux_key" {
#   key_name   = "windows-key"
#   public_key = tls_private_key.rsa.public_key_openssh # Point this to your public key file
# }

# this resource genearates a public and private key
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "foo" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "windows-key"
}

