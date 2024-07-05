variable "ami_id" {
    description = "Application EC2 AMI"
    type = string 
}

variable "ssh_key_name" {
    type    = string
    description = "The name of the SSH key pair to use for EC2 instances"
}

variable "public_sub_a_id" {
  description = "Public subnet ID"
  type        = string
}

variable "public_sub_b_id" {
  description = "Public subnet ID"
  type        = string
}

variable "http_sec_group" {
  description = "HTTP security group ID"
  type        = string
}

variable "ssh_sec_group" {
  description = "SSH security group ID"
  type        = string
}

variable "jenkins_sec_group" {
  description = "Jenkins security group ID"
  type        = string
}

variable "alb_port" {
    type    = number
    default = 80
}

variable target_group_arn {
    type    = string
}

variable app_instance_type {
    type    = string
    default = "t3.small" 
}

variable buildserver_instance_type {
    type    = string
    default = "t3.medium" 
}

variable "app_server_user_data" {
  description = "User data script for app server"
  type        = string
  default     = <<EOF
#!/bin/bash
curl -sO http://3.255.221.193:8080/jnlpJars/agent.jar
java -jar agent.jar -url http://3.255.221.193:8080/ -secret e65ef7112c6b46455c4eb634e2ca827e3c61423ee28b84c5ce4ae76550bdbcb5 -name "petclinic-cicd" -workDir "/home/ubuntu/jenkins-agent"
EOF
}