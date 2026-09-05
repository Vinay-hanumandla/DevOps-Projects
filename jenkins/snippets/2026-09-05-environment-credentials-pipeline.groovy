// last_verified: 2026-09-05 · Jenkins n/a
pipeline {
    agent any

    environment {
        // Environment variables available to all stages
        APP_ENV = 'staging'
        JAVA_HOME = '/usr/lib/jvm/java-11-openjdk'
    }

    stages {
        stage('Build') {
            steps {
                echo "Building in ${APP_ENV} environment..."
                // Use the environment variable in a command
                sh 'echo "Java home is ${JAVA_HOME}"'
            }
        }
        stage('Deploy') {
            steps {
                // Bind a secret text credential to an environment variable
                withCredentials([string(credentialsId: 'deploy-token', variable: 'DEPLOY_TOKEN')]) {
                    echo "Deploying with token length: ${DEPLOY_TOKEN.length()}"
                    // In a real pipeline, you'd use the token: sh 'curl -H "Authorization: Bearer ${DEPLOY_TOKEN}" ...'
                }
            }
        }
    }
}