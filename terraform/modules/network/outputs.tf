output "vpc_id" {
    value = aws_vpc.this.id
}

output "public_sub_a_id" {
    value = aws_subnet.public_a.id
}

output "public_sub_b_id" {
    value = aws_subnet.public_b.id
}

output "private_sub_id" {
    value = aws_subnet.private.id
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