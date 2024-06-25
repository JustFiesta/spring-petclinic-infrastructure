resource "aws_instance" "app_server_a" {
  ami           = var.ami_id
  instance_type = "t3.micro"
  subnet_id     = var.public_sub_a_id
  vpc_security_group_ids = [var.ssh_sec_group, var.http_sec_group]

  key_name      = var.ssh_key_name

  depends_on = [aws_instance.jenkins]
  
  tags {
      Name  = "capstone_project_app_a"
  }
}

resource "aws_instance" "app_server_b" {
  ami           = var.ami_id
  instance_type = "t3.micro"
  subnet_id     = var.public_sub_b_id
  vpc_security_group_ids = [var.ssh_sec_group, var.http_sec_group]

  key_name      = var.ssh_key_name

  depends_on = [aws_instance.jenkins]

  tags {
      Name  = "capstone_project_app_b"
  }
}

resource "aws_instance" "jenkins" {
  ami           = var.ami_id
  instance_type = "t3.micro"
  subnet_id     = var.public_sub_a_id
  vpc_security_group_ids = [var.ssh_sec_group, var.jenkins_sec_group]

  key_name      = var.ssh_key_name

  tags {
      Name  = "capstone_project_jenkins"
  }
}
