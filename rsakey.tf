resource "tls_private_key" "instance_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "instance_key_file" {
  content  = tls_private_key.instance_key.private_key_pem
  filename = "${path.module}/wordpress_instance_key.pem"
}

output "private_key_filename" {
  value = local_file.instance_key_file.filename
}

resource "aws_key_pair" "this" {
  key_name   = "ec2-ssh-key"
  public_key = tls_private_key.instance_key.public_key_openssh
}