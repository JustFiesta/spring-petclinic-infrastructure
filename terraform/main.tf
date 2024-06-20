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

/*
module "database" {
    source = "./modules/database"

    sec_group_id = module.network.sec_group_id
    subnet_ids   = module.network.subnet_ids
}

module "compute" {
    source = "./modules/compute"

    vpc_id       = module.network.vpc_id
    public_sub_id   = module.network.public_sub_id
    private_sub_id   = module.network.private_sub_id
    ssh_sec_group = module.network.ssh_sec_group
    http_sec_group = module.network.http_sec_group

    depends_on   = [module.network]
}
*/