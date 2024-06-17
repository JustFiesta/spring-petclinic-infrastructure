terraform {
  backend "s3" {
    bucket = "capstone-project-tf-backend"
    key    = "terraform/state"
    region = "eu-west-1"
  }
}
