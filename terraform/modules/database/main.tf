resource "aws_db_instance" "default" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = var_dbname
  username             = var_username
  password             = var_password
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  publicly_accessible  = false
  multi_az             = false
  vpc_security_group_ids = [var.rds_sec_group]

  tags = {
    Name = "capstone_rds_mysql"
  }
}