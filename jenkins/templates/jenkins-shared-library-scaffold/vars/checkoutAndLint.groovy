// last_verified: 2026-10-14 · Jenkins shared library scaffold
// Checks out a Git branch and runs a lint step. Returns the checked-out revision.

def call(Map config = [:]) {
    def repoUrl = config.repoUrl ?: 'https://github.com/example/app.git'
    def branch = config.branch ?: 'main'
    def credentialsId = config.credentialsId ?: 'github-credentials-id'
    def lintCommand = config.lintCommand ?: 'npm ci && npm run lint'

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
        sh lintCommand
    }

    return revision
}