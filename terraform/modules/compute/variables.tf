variable "ami-id" {
    description = "Application EC2 AMI"
    type = string 
}

variable "public_sub_id" {
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