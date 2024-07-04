output "vpc_id" {
    value = aws_vpc.this.id
}

output "private_sub_a_id" {
    value = aws_subnet.private_a.id
}

output "private_sub_b_id" {
    value = aws_subnet.private_b.id
}

output "http_sec_group" {
    value = aws_security_group.http.id
}

output "ssh_sec_group" {
    value = aws_security_group.ssh.id
}

output "jeknins_sec_group" {
    value = aws_security_group.jenkins.id
}

output "rds_sec_group" {
    value = aws_security_group.rds.id
}

output "db_subnet_group_name" {
    value = aws_db_subnet_group.default.id
}

output "app_target_group_arn" {
    value = aws_lb_target_group.app.id
}

output "jenkins_target_group_arn" {
    value = aws_lb_target_group.jenkins.id
}
