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

<hr>

## Project Elements

### Workstation

Workstation inside default VPC, with its own IP and opened ports: 22.

It is made for testing Terraform, Ansible and Docker.

<hr>

### Infrastructure build server

Jenkins server inside default VPC, with its own IP and opened ports: 22, and 8080.

This instance can apply or destroy incoming changes to Terraform configured AWS infrastructure.

#### Encountered problems

1. Credentials for AWS CLI in Jenkins

This bothered me for few hours. I could not run any terraform operation in Jenkins controll unit for `spring-petclinic-infrastructure`. Initially I thought it was Terraform problem.

Steps I made to fix it:

* install terraform on ec2 and point Jenkins to its binary installation folder.
* install aws cli on controll unit (it did not help at all).
* check if Jenkins sees credentials.
* set enviroment variables inside Jenkins pipeline so every agent can use AWS credentials.

Had to create credentials in Jenkins control unit, and after that set AWS enviroment variables (region and credentials) like so:

```bash
    environment {
        AWS_DEFAULT_REGION="eu-west-1"
        AWS_CREDENTIALS=credentials('mbocak-credentials')
    }
```

2. Conditionals based on choice parameters

Choice parameters when sent via Webhook do not contain any value, so FIRST one is used by default.

Had to change parameters layout a bit, so neither `Apply` or `Destroy` are taken first.

<hr>

### Infrastructure provisioning (Terraform)

Terraform is used to provide infrastructure.

Its files are stored in terraform/ catalog and are splitted into modules (`network` - vpc, sec. groups, alb, etc.; `compute` - app VM, Jenkins VM; `database` - RDB for app).

Each modules uses variables specified by use (network/variables.tf) or given from other modules output (compute, database). They contain: ports, sec. group ids, subnet ids, AMI id, etc.

#### Encountered problems

The main issue was "how to" wrap my head around this. At first I couldn't make self contained modules for testing. But after consideration i started to make changes only for one module and than test it.

<hr>

### Infrastructure Configuration (Ansible)

TODO