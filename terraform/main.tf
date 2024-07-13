terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 4.16"
        }
    }
 
    required_version = ">= 1.2.0"
}

provider "aws" {
    region    = var.region
    
    default_tags {
        tags = {
        Name        = "capstone_project"
        Owner       = "mbocak"
        Project     = "Internship_DevOps"
        }
    }
}

module "network" {
    source = "./modules/network"
}

module "database" {
    source = "./modules/database"

    db_username = var.db_username
    db_password = var.db_password
    rds_sec_group = module.network.rds_sec_group
    db_subnet_group = module.network.db_subnet_group_name
    rdb_subnet_name = module.network.db_subnet_group_name

    depends_on    = [module.network]
}

module "compute" {
    source = "./modules/compute"

    ami_id            = "ami-0776c814353b4814d" # ubuntu 24.04 LTS AMI
    public_sub_a_id   = module.network.public_sub_a_id
    public_sub_b_id   = module.network.public_sub_b_id
    ssh_sec_group     = module.network.ssh_sec_group
    http_sec_group    = module.network.http_sec_group
    target_group_arn  = module.network.target_group_arn
    ssh_key_name      = "mbocak_key_capstone"

    depends_on   = [module.network]
}
