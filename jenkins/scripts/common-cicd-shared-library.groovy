// last_verified: 2026-09-22 · Jenkins n/a
// vars/standardServicePipeline.groovy — one shared-library step covering the
// checkout -> build -> test -> image -> deploy flow our services repeat.
// In a real shared-library repo this file lives under vars/ so a Jenkinsfile
// can pull it in with @Library('team-shared-lib') _ and call it directly.
// This is one way to structure it; the docs also show splitting each stage
// into its own vars file, which fits once the steps start to diverge.

// Entry point: standardServicePipeline(config)
def call(Map config) {
    // Fail fast on missing inputs — cheaper than failing halfway through a deploy.
    ['repoUrl', 'branch', 'imageName'].each { key ->
        if (!config.get(key)) {
            error "standardServicePipeline: missing required config key '${key}'"
        }
    }
    String deployEnv = config.get('deployEnv', 'staging')
    String testPattern = config.get('testPattern', 'reports/**/*.xml')

    checkoutCode(config.repoUrl, config.branch, config.get('credentialsId'))
    buildApp(config.get('buildCommand', 'make build'))
    runTests(config.get('testCommand', 'make test'), testPattern)
    buildAndPushImage(config.imageName, config.branch, config.get('registryCredentialsId'))

    // Only branches with an explicit target deploy; anything else stops after the image push.
    if (config.branch == 'main' || config.branch.startsWith('release/')) {
        deployToEnv(config.imageName, deployEnv, config.get('deployCredentialsId'))
    } else {
        echo "standardServicePipeline: branch '${config.branch}' has no deploy target, stopping after image push."
    }
}

// Clone the service repo at the requested branch.
def checkoutCode(String repoUrl, String branch, String credentialsId) {
    checkout([
        $class: 'GitSCM',
        branches: [[name: branch]],
        userRemoteConfigs: [[
            url: repoUrl,
            credentialsId: credentialsId ?: ''
        ]]
    ])
}

// Run the service build; the default assumes a Makefile wrapper.
def buildApp(String buildCommand) {
    sh buildCommand
}

// Run tests, then archive results so the stage shows red/green in the UI.
// junit with allowEmptyResults keeps pipelines without XML output from failing here.
def runTests(String testCommand, String testPattern) {
    try {
        sh testCommand
    } finally {
        junit allowEmptyResults: true, testResults: testPattern
    }
}

// Build the container image and push it tagged with the branch name.
// The registry login stays inside withCredentials so the secret never lands in logs.
def buildAndPushImage(String imageName, String branch, String registryCredentialsId) {
    String tag = branch.replaceAll('[^a-zA-Z0-9_.-]', '-').toLowerCase()
    String ref = "${imageName}:${tag}"
    if (registryCredentialsId) {
        withCredentials([usernamePassword(
            credentialsId: registryCredentialsId,
            usernameVariable: 'REG_USER',
            passwordVariable: 'REG_PASS'
        )]) {
            sh "echo \"$REG_PASS\" | docker login --username \"$REG_USER\" --password-stdin"
        }
    }
    sh "docker build -t ${ref} ."
    sh "docker push ${ref}"
    echo "standardServicePipeline: pushed ${ref}"
}

// Deploy the tagged image to the target environment.
def deployToEnv(String imageName, String deployEnv, String deployCredentialsId) {
    if (!deployCredentialsId) {
        error "standardServicePipeline: deployCredentialsId is required to deploy to '${deployEnv}'"
    }
    withCredentials([string(credentialsId: deployCredentialsId, variable: 'DEPLOY_TOKEN')]) {
        sh "deploy --env ${deployEnv} --image ${imageName} --token \"$DEPLOY_TOKEN\""
    }
}

// Verify: configure a Jenkinsfile with @Library('team-shared-lib') _,
// call standardServicePipeline(repoUrl: ..., branch: 'main', imageName: '...'),
// and confirm the run goes green through checkout, build, test, image push,
// and deploy — a feature branch should stop cleanly after the image push.
