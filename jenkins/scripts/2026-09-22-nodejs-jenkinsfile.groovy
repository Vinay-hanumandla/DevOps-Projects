# last_verified: 2026-09-22 · jenkins L2
# First attempt at a Node.js Jenkinsfile - following the declarative pipeline tutorial
# Got stuck on: docker push creds syntax, fixed by using withRegistry block
# What I'd try next: add SonarQube stage, parallelize test/lint

pipeline {
    agent any

    environment {
        NODE_VERSION = '20'
        APP_NAME = 'my-node-app'
        DOCKER_REGISTRY = 'docker.io/myorg'
        TARGET_ENV = 'staging'
    }

    tools {
        nodejs "NodeJS-${env.NODE_VERSION}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm ci'
            }
            post {
                failure {
                    echo 'npm ci failed - check package-lock.json and registry access'
                }
            }
        }

        stage('Build') {
            steps {
                sh 'npm run build'
            }
            post {
                failure {
                    echo 'Build failed - check TypeScript/ESLint output above'
                }
            }
        }

        stage('Test') {
            steps {
                sh 'npm test'
            }
            post {
                always {
                    junit 'test-results/*.xml'
                }
                failure {
                    echo 'Tests failed - see JUnit report for details'
                }
            }
        }

        stage('Lint & Type Check') {
            steps {
                sh 'npm run lint'
                sh 'npm run typecheck'
            }
            post {
                failure {
                    echo 'Lint or type check failed - fix reported issues'
                }
            }
        }

        stage('Docker Build') {
            when {
                branch 'main'
            }
            steps {
                script {
                    dockerImage = docker.build("${DOCKER_REGISTRY}/${APP_NAME}:${BUILD_NUMBER}")
                }
            }
        }

        stage('Docker Push') {
            when {
                branch 'main'
            }
            steps {
                script {
                    docker.withRegistry("https://${DOCKER_REGISTRY}", 'dockerhub-creds') {
                        dockerImage.push()
                        dockerImage.push('latest')
                    }
                }
            }
        }

        stage('Archive Artifacts') {
            steps {
                archiveArtifacts artifacts: 'dist/**/*', fingerprint: true
                archiveArtifacts artifacts: 'test-results/**/*', fingerprint: true
            }
        }

        stage('Deploy to Staging') {
            when {
                branch 'main'
                environment name: 'TARGET_ENV', value: 'staging'
            }
            steps {
                sh '''
                    kubectl set image deployment/${APP_NAME} \
                        ${APP_NAME}=${DOCKER_REGISTRY}/${APP_NAME}:${BUILD_NUMBER} \
                        --namespace=staging
                    kubectl rollout status deployment/${APP_NAME} --namespace=staging --timeout=300s
                '''
            }
        }

        stage('Deploy to Live') {
            when {
                branch 'main'
                environment name: 'TARGET_ENV', value: 'live'
            }
            steps {
                input message: 'Approve live deployment?', ok: 'Deploy'
                sh '''
                    kubectl set image deployment/${APP_NAME} \
                        ${APP_NAME}=${DOCKER_REGISTRY}/${APP_NAME}:${BUILD_NUMBER} \
                        --namespace=live
                    kubectl rollout status deployment/${APP_NAME} --namespace=live --timeout=300s
                '''
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo "Pipeline succeeded for ${APP_NAME} #${BUILD_NUMBER}"
        }
        failure {
            echo "Pipeline failed for ${APP_NAME} #${BUILD_NUMBER}"
        }
        unstable {
            echo "Pipeline unstable for ${APP_NAME} #${BUILD_NUMBER}"
        }
    }
}