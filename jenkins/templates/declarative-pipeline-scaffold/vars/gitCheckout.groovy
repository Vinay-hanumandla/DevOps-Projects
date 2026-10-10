// last_verified: 2026-10-10 · Jenkins shared library
// Checks out a Git repository with credential binding. Returns the commit SHA.

def call(Map params) {
    def repoUrl = params.repoUrl ?: 'https://github.com/example/repo.git'
    def branch = params.branch ?: 'main'
    def credentialsId = params.credentialsId ?: 'git-credentials-id'
    def shallow = params.shallow ?: false

    def revision
    stage('Checkout') {
        checkout([
            $class: 'GitSCM',
            branches: [[name: "*/${branch}"]],
            doGenerateSubmoduleConfigurations: false,
            extensions: shallow ? [[$class: 'CloneOption', depth: 1, noTags: true, shallow: true]] : [],
            submoduleCfg: [],
            userRemoteConfigs: [[url: repoUrl, credentialsId: credentialsId]]
        ])
        revision = sh(
            script: 'git rev-parse HEAD',
            returnStdout: true
        ).trim()
    }

    return revision
}