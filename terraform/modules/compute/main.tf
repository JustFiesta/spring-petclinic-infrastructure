resource "aws_instance" "app_server_a" {
  ami                    = var.ami_id
  instance_type          = var.app_instance_type
  subnet_id              = var.public_sub_a_id
  vpc_security_group_ids = [var.ssh_sec_group, var.http_sec_group]

  key_name = var.ssh_key_name

  depends_on = [aws_instance.jenkins]

  tags = {
    Name = "webserver_a"
  }
}

resource "aws_instance" "app_server_b" {
  ami                    = var.ami_id
  instance_type          = var.app_instance_type
  subnet_id              = var.public_sub_b_id
  vpc_security_group_ids = [var.ssh_sec_group, var.http_sec_group]

  key_name = var.ssh_key_name

  depends_on = [aws_instance.jenkins]

  tags = {
    Name = "webserver_b"
  }
}

resource "aws_instance" "jenkins" {
  ami                    = var.ami_id
  instance_type          = var.buildserver_instance_type
  subnet_id              = var.public_sub_a_id
  vpc_security_group_ids = [var.ssh_sec_group]

  key_name = var.ssh_key_name

  root_block_device {
    volume_size = 30
  }

  tags = {
    Name = "capstone_project_jenkins_buildserver"
  }
}

# Register Instances to Target Group
resource "aws_lb_target_group_attachment" "app_server_a" {
  target_group_arn = var.target_group_arn
  target_id        = aws_instance.app_server_a.id
  port             = var.alb_port
}

resource "aws_lb_target_group_attachment" "app_server_b" {
  target_group_arn = var.target_group_arn
  target_id        = aws_instance.app_server_b.id
  port             = var.alb_port
}
