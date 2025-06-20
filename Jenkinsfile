properties([
    parameters([
        string(
            defaultValue: 'dev',
            name: 'Environment'
        ),
        choice(
            choices: ['plan', 'apply', 'destroy'], 
            name: 'Terraform_Action'
        )])
])
pipeline {
    agent any
 
    environment {
        GOOGLE_APPLICATION_CREDENTIALS = "${env.WORKSPACE}/gcp-service-account-json.json"
    }
 
    stages {
        stage('Checkout') {
            steps {
                // Checkout Terraform code from your GitHub repository
                git branch: 'master', credentialsId: 'github-credentials-id', url: 'https://github.com/justShamik/GKE3TierTerra.git'
            }
        }
 
        stage('Install Terraform') {
            steps {
                // Install Terraform if it's not already installed
                sh '''
                    if ! [ -x "$(command -v terraform)" ]; then
                        wget https://releases.hashicorp.com/terraform/1.5.0/terraform_1.5.0_linux_amd64.zip unzip terraform_1.5.0_linux_amd64.zip
                        sudo mv terraform /usr/local/bin/
                    fi
                '''
            }
        }
        
       stage('Initialize Terraform') {
            steps {
                script {
                    // Inject the service account key file
                    withCredentials([file(credentialsId: 'gcp-service-account-json', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                        // Initialize Terraform
                        sh 'terraform init'
                    }
                }
            }
        }
        
       stage('Terraform Plan') {
            steps {
                script {
                    // Inject the service account key file
                    withCredentials([file(credentialsId: 'gcp-service-account-json', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                        // Initialize Terraform
                        sh 'terraform plan'
                    }
                }
            }
        }
        
        stage('Apply Terraform') {
            steps {
                script {
                    // Apply Terraform configurations
                    withCredentials([file(credentialsId: 'gcp-service-account-json', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                        script {    
                        if (params.Terraform_Action == 'plan') {
                            sh "terraform plan"
                        }   else if (params.Terraform_Action == 'apply') {
                            sh "terraform apply -auto-approve"
                        }   else if (params.Terraform_Action == 'destroy') {
                            sh "terraform destroy -auto-approve"
                        } else {
                            error "Invalid value for Terraform_Action"
                        }
                    }
                    }
                }
            }
        }
       
    }
 
    post {
        always {
            // Cleanup workspace
            cleanWs()
        }
    }
}