// last_verified: 2026-09-23 · Jenkins shared library
// Checks out a Git branch and runs a lint step. Returns the checked-out revision.

def call(String repoUrl, String branch, String credentialsId) {
    def revision
    stage('Checkout') {
        checkout([
            $class: 'GitSCM',
            branches: [[name: "*/${branch}"]],
            userRemoteConfigs: [[url: repoUrl, credentialsId: credentialsId]]
        ])
        revision = sh(
            script: 'git rev-parse HEAD',
            returnStdout: true
        ).trim()
    }

    stage('Lint') {
        sh 'npm ci && npm run lint'
    }

    return revision
}