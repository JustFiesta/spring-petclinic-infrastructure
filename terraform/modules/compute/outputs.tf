output "app_server_public_a_ip" {
  value = aws_instance.app_server_a.public_ip
}

output "app_server_public_b_ip" {
  value = aws_instance.app_server_b.public_ip
}

output "jenkins_public_ip" {
  value = aws_instance.jenkins.public_ip
}
