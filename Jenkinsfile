pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION="eu-west-1"
        AWS_CREDENTIALS=credentials('mbocak-credentials')
    }

    parameters {
        choice(name: 'ACTION', choices: ['Apply', 'Destroy'], description: 'Choose the action to perform')
    }

    stages {
        stage('Check ACTION status') {
            steps {
                echo "${ACTION}"
            }
        }
        stage('Checkout scm') {
            steps {
                checkout scm
            }
        }

        stage('Terraform init') {
            steps {
                dir('terraform') {
                    sh 'terraform init -no-color'
                }
            }
        }

        stage('Terraform format') {
            steps {
                dir('terraform') {
                    sh 'terraform fmt -no-color'
                }
            }
        }

        stage('Terraform validate') {
            steps {
                dir('terraform') {
                    sh 'terraform validate -no-color'
                }
            }
        }

        stage('Terraform scan') {
            steps {
                dir('terraform') {
                    sh 'terraform fmt -check -no-color'
                }
            }
        }

        stage('Terraform plan') {
            steps {
                dir('terraform') {
                    sh 'terraform plan -out=tfplan -no-color'
                }
            }
        }

        stage('Terraform apply') {
            when {
                allOf {
                    expression { params.ACTION != null }
                    expression { params.ACTION == 'Apply' }
                }
            }
            steps {
                input message: 'Apply new changes?', ok: 'Apply'
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'mbocak-credentials']]) {
                    sh 'terraform apply -auto-approve -no-color tfplan'
                }
            }
        }

        stage('Terraform destroy') {
            when {
                allOf {
                    expression { params.ACTION != null }
                    expression { params.ACTION == 'Apply' }
                }
            }
            steps {
                input message: 'Want to destroy resources?', ok: 'Destroy'
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'mbocak-credentials']]) {
                    sh 'terraform destroy -auto-approve -no-color'
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
