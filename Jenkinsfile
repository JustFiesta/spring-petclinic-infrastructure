pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION="eu-west-1"
        AWS_CREDENTIALS=credentials('mbocak-credentials')
    }

    stages {
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
                    sh 'terraform plan --auto-approve -out=tfplan -no-color'
                }
            }
        }

        stage('Terraform apply') {
            steps {
                input message: 'Apply new changes?', ok: 'Apply'
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'mbocak-credentials']]) {
                    sh 'terraform apply -no-color tfplan'
                }
            }
        }

        stage('Terraform destroy') {
            steps {
                input message: 'Want to destroy resources?', ok: 'Destroy'
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'mbocak-credentials']]) {
                    sh 'terraform destroy --auto-approve -no-color'
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
