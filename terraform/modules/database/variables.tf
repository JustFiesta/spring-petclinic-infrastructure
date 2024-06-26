variable "db_name" {
    type    = string
    default = "spring-petclinic"
}

variable "db_username" {
    type      = string
    sensitive = true
}

variable "db_password" {
    type      = string
    sensitive = true
}