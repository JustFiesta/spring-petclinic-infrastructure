# Spring-petclinic infrastructure

This repository contains automation of insfrastructure deployment for spring-petclinic app.

All instances provided are run on Ubuntu 24 LTS.

## Tools used

* Bash scripts - install tools on workstation
* Terraform - provide AWS infrastructure for app
* Ansible - configure EC2 instances
* Jenkins - integration server for infrastrucuture repository. Acts as Controller.

<hr>

## Setup infrastructure initial infrastructure (workstation + Jenkins Controller)

### Setup workstation

Workstation is used to test given infrastructure and install packages to targets with Ansible.

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
    ```

6. Configure AWS CLI

    ```bash
    aws configure
    ```

7. Initilize terraform with S3 backend

    ```bash
    cd ./terraform
    terraform init -backend-config=backend.tf
    ```

### Setup Jenkins Controller

Provide EC2 instance in Default VPC and install Java and Jenkins accrodint to [this tutorial](https://www.jenkins.io/doc/book/installing/linux/#debianubuntu).

It is used for integrating infrastructure code and deploying it to AWS, and as a Controller for application buildserver.

1. Install according to tutorial on EC2 (Java + Jenkins + Terraform + AWS CLI)

2. Install recommended plugins, set user, password, etc.

3. Setup credentials for:

    * Dockerhub (docker-cred)
    * GitHub
    * AWS

4. Setup Gradle tool (version 8.7 with name "8.7")

5. Add GitHub webhook to infrastructure repository.

6. Add multibranch pipeline with GitHub project and SCM pipeline.

After this configuration code can be automaticlly: formatted, valdiated. One can Apply/Destory infrastructure with manual job in Jenkins Controller.

<hr>

## Explanation of components

### Workstation

Workstation inside default VPC, with its own IP and opened ports: 22.

It is made for testing Terraform, Ansible and Docker.

<hr>

### Jenkins Controller

Jenkins controller setted up manually in Default VPC as a part of workspace, with its own IP and opened ports: 22, 8080.

Main objective of this server is to check, integrate Terraform infrastrcuture and provide it as manual job. Additionally it acts as controller for application buildserver.

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

1. The main issue was "how to" wrap my head around this. At first I couldn't make self contained modules for testing. But after consideration i started to make changes only for one module and than test it.

2. Second one was about RDS - it just could not take given security groups.

<hr>

### Infrastructure Configuration (Ansible)

Ansible is used to configure EC2 app instances - install docker on webservers and Jenkins on buildserver. VM's have pulic IP address so Ansible can connect to them via SSH.

No ansible roles where needed in my opinion - they were unnessesary complication for simple project.
