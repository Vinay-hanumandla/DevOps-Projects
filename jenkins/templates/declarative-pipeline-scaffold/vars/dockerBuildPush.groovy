// last_verified: 2026-10-10 · Jenkins shared library
// Builds a Docker image, tags it, and pushes it to a registry. Returns the image ref.

def call(Map params) {
    def image = params.image ?: 'app'
    def tag = params.tag ?: env.BUILD_NUMBER
    def registry = params.registry ?: 'registry.example.com'
    def credentialsId = params.credentialsId ?: 'registry-credentials-id'
    def dockerfile = params.dockerfile ?: 'Dockerfile'
    def buildArgs = params.buildArgs ?: [:]
    def context = params.context ?: '.'

    def fullRef = "${registry}/${image}:${tag}"
    def latestRef = "${registry}/${image}:latest"

    def buildArgsString = buildArgs.collect { k, v -> "--build-arg ${k}=${v}" }.join(' ')

    stage('Build image') {
        sh "docker build ${buildArgsString} -t ${fullRef} -t ${latestRef} -f ${dockerfile} ${context}"
    }

    stage('Push image') {
        withCredentials([usernamePassword(
            credentialsId: credentialsId,
            usernameVariable: 'REGISTRY_USER',
            passwordVariable: 'REGISTRY_PASS'
        )]) {
            sh "echo \"${REGISTRY_PASS}\" | docker login -u \"${REGISTRY_USER}\" ${registry} --password-stdin"
            sh "docker push ${fullRef}"
            sh "docker push ${latestRef}"
        }
    }

    return fullRef
}