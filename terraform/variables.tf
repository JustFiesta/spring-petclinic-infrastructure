variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "db_username" {
  description = "Username for the RDS instance"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Password for the RDS instance"
  type        = string
  sensitive   = true
  default     = "password"
}