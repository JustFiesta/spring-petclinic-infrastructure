variable "ami_id" {
    description = "Application EC2 AMI"
    type = string 
}

variable "ssh_key_name" {
    type    = string
    description = "The name of the SSH key pair to use for EC2 instances"
}

variable "private_sub_a_id" {
  description = "Private subnet ID"
  type        = string
}

variable "private_sub_b_id" {
  description = "Private subnet ID"
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

variable "alb_app_port" {
    type    = number
    default = 80
}

variable "alb_jenkins_port" {
    type    = number
    default = 8080
}

variable app_target_group_arn {
    type    = string
}

variable jenkins_target_group_arn {
    type    = string
}

variable app_instance_type {
    type    = string
    default = "t3.small" 
}

variable buildserver_instance_type {
    type    = string
    default = "t3.small" 
}