locals {
  is_windows = substr(pathexpand("~"), 0, 1) == "/" ? false : true
  key_file   = pathexpand("~/.ssh/aws_poc.pem")
}

locals {
  bash           = "chmod 400 ${local.key_file}"
  bash_ssh       = "eval `ssh-agent` ; ssh-add -k ${local.key_file}"
  powershell     = "icacls ${local.key_file} /inheritancelevel:r /grant:r username:R"
  powershell_ssh = "ssh-agent ; ssh-add -k ~/.ssh/aws_poc.pem"
}

resource "tls_private_key" "rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "key_pair" {
  key_name   = "aws_ec2_key"
  public_key = tls_private_key.rsa_key.public_key_openssh
}

resource "aws_key_pair" "key_pair_secondary" {
  key_name   = "aws_ec2_key"
  public_key = tls_private_key.rsa_key.public_key_openssh
  provider = aws.sydney
}

resource "local_file" "my_key_file" {
  content  = tls_private_key.rsa_key.private_key_pem
  filename = local.key_file

  provisioner "local-exec" {
    command = local.is_windows ? local.powershell : local.bash
  }

  provisioner "local-exec" {
    command = local.is_windows ? local.powershell_ssh : local.bash_ssh
  }
}
