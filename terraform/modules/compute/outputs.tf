output "app_server_public_ip" {
  value = aws_instance.app_server.public_ip
}
output "jenkins_public_ip" {
  value = aws_instance.jenkins.public_ip
}
