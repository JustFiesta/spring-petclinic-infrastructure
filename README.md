# Spring-petclinic infrastructure

This repository contains automation of insfrastructure deployment for spring-petclinic app.

All instances provided run on Ubuntu 24 LTS.

## Tools used

* Bash scripts - install tools on workstation
* Terraform - provide AWS infrastructure for app
* Ansible - configure EC2 instances
* Jenkins - integration server for infrastrucuture repository. Acts as Controller.

<hr>

## Directory structure

* `ansible/` - contains playbooks and hosts file for:
  
  * installing dependencies (Docker - webservers, Java - Jenkins agent) - `install-dependencies.yml`
  * configuring build agent service - `configure-petclinic-service.yml`

* `terraform/` - contains backend configuration and modules for infrastructure (`compute/`, `database/`, `network/`)

* `workstation-setup/` - setup script for workstation - installs: Docker, Terraform, AWS CLI and Ansible.

* `Jenkinsfile` - pipeline for terraform infrastructure. Runs format, validation and Applies/Destroies infrastructure.

<hr>

## Overview

I made an wokrstation and Jenkins Controller in default VPC.

Jenkins Controller provides further infrastructure with manual job via Terraform. It needs correct credentials to be configured (mentioned in Setup section).

Provided infrastrcue consists of:

* VPC
* 4 subnets - 2 private (RDS), 2 public (application and Jenkins Agent)
* 3 EC2 - 2 for application and one for Jenkins Agent
* RDS - MySQL database for applications
* Application Load Balancer - targeted at application Instances
* Internet Gateway for VPC
* Security Groups for: application (80), Jenkins (8080), SSH (22)

SSH key specified in terraform/main.tf is used to connect to instances. If one does not have any key the easiest way is to create one in AWS Console and change key name in mentioned file.

Also one needs to SCP private key into Workstation. Otherwise it will not be able to connect via Ansible to servers.

<hr>

## Explanation of components

### Workstation

Workstation setted up manually inside Default VPC, with its own IP and opened ports: 22.

Mainly it is used to install needed packages, deploy Agent service and redeploy web applications with **Ansible**.

It can also test Terraform and Docker.

### Jenkins Controller

Jenkins controller setted up manually in Default VPC as a part of workspace, with its own IP and opened ports: 22, 8080.

Main objective of this server is to check Terraform infrastrcuture and **provide/destroy** it as manual job. Additionally it acts as controller for application buildserver.

#### Encountered problems

1. Credentials for AWS CLI in Jenkins

    This bothered me for few hours. I could not run any terraform operation in Jenkins controll unit for `spring-petclinic-infrastructure`. Initially I thought it was Terraform problem.

    Steps I made to fix it:

    * install terraform on ec2 and point Jenkins to its binary installation folder.
    * install aws cli on controll unit.
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

### Infrastructure provisioning (Terraform)

Terraform is used to provide infrastructure.

Its files are stored in `terraform/` catalog and are splitted into modules (`network` - vpc, sec. groups, alb, etc.; `compute` - app VM, Jenkins agent VM; `database` - RDB for app).

Each modules uses variables specified in `terraform/module_name/variables.tf` or given from other modules output. They contain: ports, sec. group ids, subnet ids, AMI id, etc. Variables without default values are set in `terraform/main.tf`, other are setted with default values in each modules `variables.tf`. 

#### Encountered problems

1. The main issue was "how to" wrap my head around this. At first I couldn't make self contained modules for testing, every part was made subsecuentlly. But after consideration I started to make changes only for one module and than test it.

2. Second one was about RDS - it just could not take given security groups due to typo in configuration.

### Infrastructure Configuration (Ansible)

Ansible is used to configure EC2 app instances - install Docker on webservers and Java on buildserver. VM's have pulic IP address so Ansible can connect to them via SSH.

Also it provides Jenkins Agent with configuration as systemd service - `petclinic-cicd.service`.

The `hosts.yml` needs to be changed according to given IP addreses in AWS Console. Only then one can provide instances with packages.
The `configure-petclinic-service.yml` also needs to be changed according to ones needs - IP of server and secret might change according to configuration.

<hr>

## Setup initial infrastructure (workstation + Jenkins Controller)

### Setup workstation

Workstation is used to **install packages to targets with Ansible** and test given infrastructure.

0. `scp` **public key** file into workstations `/home/ubuntu/.ssh` (key is specified in /terraform/main.tf file, on default it its `mbocak_key_capstone`)
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
    terraform init
    ```

8. Correct IP addresses of hosts according to given IP Addresses from AWS Contsole (server_a, server_b, jenkins_buildserver) in `hosts.yml` file.

### Setup Jenkins Controller

Provide EC2 instance in Default VPC and install Java and Jenkins accroding to [this tutorial](https://www.jenkins.io/doc/book/installing/linux/#debianubuntu).

It is used for integrating infrastructure code and deploying it to AWS, and as a Controller for application buildserver.

1. Install according to tutorial on EC2 - Java, Jenkins, Terraform, AWS CLI.

2. Install recommended plugins, set user, password, etc.

3. Setup credentials for:

    * Dockerhub (docker-cred) - Docker Hub credentials
    * GitHub (github-cred) - GitHub credentials for account where both repositories reside
    * AWS (mbocak-credentials) - access keys for AWS account
    * SSH Key (aws-key) - for connecting to workstation and use ansible to redeploy application
    * workstation IP (workstation-ip) - for secure access to workstation punlic IP address from manual job

4. Setup Gradle tool (version 8.7 with name "8.7").

5. Add GitHub webhooks to infrastructure and application repository.

6. Add multibranch pipeline project with GitHub **with tags dicovering** project and SCM pipeline for *spring-petclinic application*.

7. Add pipeline project with GitHub and SCM pipeline for *spring-petclinic-infrastructure* repository.

After this configuration code can be automaticlly: formatted, valdiated. One can Apply/Destory infrastructure with manual job in Jenkins Controller.

One also needs to add Agent with commands given in Jenkins panel. Agent should be added in `configure-petclinic-service.yml` inside `ansible/playbooks/`.
There are some sample variables. User needs to input correct IP address and secret from Jenkins Controller, other are optional.

<hr>

## Setup application infrastructure

1. Inside workstation: Add correct IP addreses to `hosts.yml`.
2. Inside workstation: Change IP and secret in `configure-petclinic-service.yml` inside `ansible/playbooks`.
3. Inside workstation: Run playbook for configuring application and agent.

    ```bash
    cd spring-petclinic-infrastructure/ansible
    ansible-playbook playbooks/setup.yml
    ```

    `setup.yml` combines playbooks:
    * install-dependencies.yml - installs docker on webservers and java on build agent.
    * `configure-petclinic-service.yml` - configures and enables build agent service for connecting to Jenkins controller.

    Note: Before using ansible copy ID to hosts with `ssh-copy-id`.

4. Deploy app infrastructure from Manual job inside Jenkins Controller - check *spring-petclinic application* README.

### Redeploy application

Application is redeploied via manual Job, which uses Ansible from Workstation to redeploy docker containers - check *spring-petclinic* application README, section Deployment.

In shortcut deployment needs RDS_DB variable to be setted manually on workstation before running Deploy job in Jenkins Controller.
