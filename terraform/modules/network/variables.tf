variable "region" {
    type    = string
    default = "eu-west-1"
}

variable "vpc_cidr" {
    type    = string
    default = "10.0.0.0/16"
}

variable "public_sub" {
    type    = string
    default = "10.0.1.0/24"
}

variable "private_sub" {
    type    = string
    default = "10.0.2.0/24"
}