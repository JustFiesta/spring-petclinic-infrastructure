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