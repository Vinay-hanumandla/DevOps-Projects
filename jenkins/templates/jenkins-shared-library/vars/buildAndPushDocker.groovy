// last_verified: 2026-09-23 · Jenkins shared library
// Builds a Docker image, tags it, and pushes it to a registry. Returns the image ref.

def call(String image, String tag, String registry) {
    def fullRef = "${registry}/${image}:${tag}"

    stage('Build image') {
        sh "docker build -t ${fullRef} -t ${registry}/${image}:latest ."
    }

    stage('Push image') {
        withCredentials([usernamePassword(
            credentialsId: 'registry-credentials-id',
            usernameVariable: 'REGISTRY_USER',
            passwordVariable: 'REGISTRY_PASS'
        )]) {
            sh "echo \"${REGISTRY_PASS}\" | docker login -u \"${REGISTRY_USER}\" ${registry} --password-stdin"
            sh "docker push ${fullRef}"
            sh "docker push ${registry}/${image}:latest"
        }
    }

    return fullRef
}