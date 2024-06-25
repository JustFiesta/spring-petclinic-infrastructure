resource "aws_instance" "app_server" {
  ami           = var.ami-id
  instance_type = "t3.micro"
  subnet_id     = var.public_sub_a_id
  vpc_security_group_ids = [var.http_sec_group]

  depends_on = [aws_instance.jenkins]
}

resource "aws_instance" "app_server" {
  ami           = var.ami-id
  instance_type = "t3.micro"
  subnet_id     = var.public_sub_b_id
  vpc_security_group_ids = [var.http_sec_group]

  depends_on = [aws_instance.jenkins]
}

resource "aws_instance" "jenkins" {
  ami           = var.ami-id
  instance_type = "t3.micro"
  subnet_id     = var.public_sub_a_id
  vpc_security_group_ids = [var.ssh_sec_group, var.jenkins_sec_group]
}
