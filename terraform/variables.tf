variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "aws_access_key" {
    sensitive = true
}
variable "aws_secret_key" {
    sensitive = true
}