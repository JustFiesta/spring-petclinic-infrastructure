# Spring-petclinic infrastructure

This repository contains automation of insfrastructure deployment for spring-petclinic app.

## Tools used

* Bash scripts - install tools on workstation
* Terraform - provide AWS infrastructure for app
* Ansible - configure EC2 instances

<hr>

## Setup workstation

1. Clone repository into workstation with

    ```bash
    git clone https://github.com/JustFiesta/spring-petclinic-infrastructure
    ```

2. Go to workstation-setup directory

    ```bash
    cd ./spring-petclinic-infrastructure/workstation-setup/
    ```

3. Add execute premissions

    ```bash
    chmod +x ./setup.sh
    ```

4. Run script as superuser (for apt install)

    ```bash
    sudo ./setup.sh
    ```

5. Export Terraform enviroment variables

    ```bash
    export TF_VAR_aws_access_key=<access_key_value>
    export TF_VAR_aws_secret_key=<secret_key_value>
    export TF_VAR_db_username=<username_value>     
    export TF_VAR_db_password=<password_value>
    ```

6. Initilize terraform with S3 backend

    ```bash
    cd ./terraform
    terraform init -backend-config=backend.tf
    ```
