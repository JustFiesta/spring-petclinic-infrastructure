variable "db_name" {
  description = "Name of the database"
  type        = string
  default     = "spring-petclinic"
}

variable "db_username" {
  description = "Username for the database"
  type        = string
}

variable "db_password" {
  description = "Password for the database"
  type        = string
  sensitive   = true
}

variable "rds_sec_group" {
  description = "Security group ID for the RDS instance"
  type        = string
}

variable "db_subnet_group" {
  description = "Subnet group name for the RDS instance"
  type        = string
}