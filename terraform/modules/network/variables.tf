variable "region" {
    type    = string
    default = "eu-west-1"
}

variable "vpc_cidr" {
    type    = string
    default = "10.0.0.0/16"
}

variable "private_a" {
    type    = string
    default = "10.0.30.0/24"
}

variable "private_b" {
    type    = string
    default = "10.0.40.0/24"
}

variable "alb_app_port" {
    type    = number
    default = 80
}

variable "alb_jenkins_port" {
    type    = number
    default = 8080
}