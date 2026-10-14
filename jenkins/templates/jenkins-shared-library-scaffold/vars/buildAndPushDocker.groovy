// last_verified: 2026-10-14 · Jenkins shared library scaffold
// Builds a Docker image, tags it, and pushes it to a registry. Returns the image ref.

def call(Map config = [:]) {
    def image = config.image ?: 'app'
    def tag = config.tag ?: env.BUILD_ID ?: env.BUILD_NUMBER ?: 'latest'
    def registry = config.registry ?: 'registry.example.com'
    def credentialsId = config.credentialsId ?: 'registry-credentials-id'
    def dockerfile = config.dockerfile ?: 'Dockerfile'
    def buildArgs = config.buildArgs ?: [:]
    def context = config.context ?: '.'
    def target = config.target
    def platform = config.platform
    def cacheFrom = config.cacheFrom
    def cacheTo = config.cacheTo

    def fullRef = "${registry}/${image}:${tag}"
    def latestRef = "${registry}/${image}:latest"

    def buildArgsStr = buildArgs.collect { "--build-arg ${it.key}=${it.value}" }.join(' ')
    def targetStr = target ? "--target ${target}" : ''
    def platformStr = platform ? "--platform ${platform}" : ''
    def cacheFromStr = cacheFrom ? "--cache-from ${cacheFrom}" : ''
    def cacheToStr = cacheTo ? "--cache-to ${cacheTo}" : ''

    stage('Build image') {
        sh """
            docker build ${buildArgsStr} ${targetStr} ${platformStr} ${cacheFromStr} ${cacheToStr} \\
                -t ${fullRef} -t ${latestRef} \\
                -f ${dockerfile} ${context}
        """
    }

    stage('Push image') {
        withCredentials([usernamePassword(
            credentialsId: credentialsId,
            usernameVariable: 'REGISTRY_USER',
            passwordVariable: 'REGISTRY_PASS'
        )]) {
            sh """
                echo "${REGISTRY_PASS}" | docker login -u "${REGISTRY_USER}" ${registry} --password-stdin
                docker push ${fullRef}
                docker push ${latestRef}
            """
        }
    }

    return fullRef
}