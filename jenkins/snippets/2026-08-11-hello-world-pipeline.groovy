// last_verified: 2026-08-11 · jenkins n/a
pipeline {
    agent any
    stages {
        stage('Hello') {
            steps {
                echo 'Hello, World!'
            }
        }
    }
}
