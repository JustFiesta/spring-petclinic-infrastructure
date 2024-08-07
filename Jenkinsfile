pipeline {
    agent { label 'build' } 

    environment {
        AWS_DEFAULT_REGION="eu-west-1"
        AWS_CREDENTIALS=credentials('mbocak-credentials')
    }

    parameters {
        choice(name: 'ACTION', choices: ['Check', 'Apply', 'Destroy'], description: 'Choose the action to perform')
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
                    sh 'terraform fmt -no-color -recursive'
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
                    sh 'terraform plan -no-color'
                }
            }
        }

        stage('Terraform apply') {
            when {
                expression { params.ACTION == 'Apply' }
            }
            steps {
                dir('terraform') {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'mbocak-credentials']]) {
                        sh 'terraform apply -auto-approve -no-color'
                    }
                }
            }
        }

        stage('Terraform destroy') {
            when {
                expression { params.ACTION == 'Destroy' }
            }
            steps {
                dir('terraform') {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'mbocak-credentials']]) {
                        sh 'terraform destroy -auto-approve -no-color'
                    }
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
