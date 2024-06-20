pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION="eu-west-1"
        AWS_CREDENTIALS=credentials('mbocak-credentials')
    }

    stages{
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

        stage('Terraform plan') {
            steps {
                dir('terraform') {
                    sh 'terraform plan -no-color'
                }
            }
        }

        stage('Terraform apply') {
            steps {
                input message: 'Czy na pewno chcesz zastosować zmiany?', ok: 'Zastosuj'
                sh 'terraform apply --auto-approve -no-color'
            }
        }

        stage('Terraform destroy') {
            steps {
                input message: 'Czy na pewno chcesz zniszczyć zasoby?', ok: 'Zniszcz'
                sh 'terraform destroy --auto-approve -no-color'
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}