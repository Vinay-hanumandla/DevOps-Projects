// last_verified: 2026-09-19 · Jenkins n/a
// Minimal Jenkinsfile using a shared library plus credentials binding.
// I wanted one pipeline that pulls a helper from our shared lib and then
// uses a secret without ever printing it. Following the tutorial got me the
// declarative skeleton; the @Library line was the part that kept failing
// until I matched the name to the one configured under
// Manage Jenkins » System » Global Pipeline Libraries.

// doing the lib import here because the docs example put it after pipeline
// and that failed — the annotation has to sit outside the block
@Library('team-shared-lib') _

pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                // sayHello comes from vars/sayHello.groovy in the shared lib;
                // got stuck on MissingMethodException here — turned out the
                // lib name in the annotation didn't match the configured one
                sayHello('web')
            }
        }
        stage('Deploy') {
            steps {
                // bind the secret text credential to an env var for this block
                withCredentials([string(credentialsId: 'deploy-token', variable: 'DEPLOY_TOKEN')]) {
                    // not echoing the token itself, just proving it is set
                    sh 'echo "token length: ${#DEPLOY_TOKEN}"'
                }
            }
        }
    }
}
// What I'd try next: pass the bound credential into a shared-lib step
// (e.g. libDeploy(env.DEPLOY_TOKEN)) instead of inlining the shell call.
