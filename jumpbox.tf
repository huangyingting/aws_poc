resource "aws_instance" "jumpbox" {
  ami                    = data.aws_ami.ubuntu_secondary.id
  instance_type          = "t2.micro"
  key_name               = "aws_ec2_key"
  subnet_id              = aws_subnet.pub_sub_2a.id
  vpc_security_group_ids = [aws_security_group.jumpbox.id]
  tags = {
    Name    = "jumpbox"
    Project = "aws-poc"
  }
  provider = aws.sydney
}
