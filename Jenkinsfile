pipeline {
    agent any

    stages{
        stage('Checkout scm') {
            steps {
                checkout scm
            }
        }
        stage('Terraform init') {
            steps {
                sh 'cd terraform/'
                sh 'terraform init'
            }
        }
        stage('Terraform format') {
            steps {
                sh 'terraform fmt'
            }
        }

        stage('Terraform validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Terraform plan') {
            steps {
                sh 'terraform plan'
            }
        }

        stage('Terraform apply') {
            steps {
                input message: 'Czy na pewno chcesz zastosować zmiany?', ok: 'Zastosuj'
                sh 'terraform apply --auto-approve'
            }
        }

        stage('Terraform destroy') {
            steps {
                input message: 'Czy na pewno chcesz zniszczyć zasoby?', ok: 'Zniszcz'
                sh 'terraform destroy --auto-approve'
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}