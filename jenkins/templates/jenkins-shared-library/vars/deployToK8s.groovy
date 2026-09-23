// last_verified: 2026-09-23 · Jenkins shared library
// Patches a Kubernetes Deployment image and waits for the rollout to complete.

def call(String imageRef, String namespace, String deployment) {
    stage('Configure kubeconfig') {
        withKubeCredentials([kubeConfig: 'kubeconfig-credentials-id']) {
            stage('Set image') {
                sh "kubectl set image deployment/${deployment} app=${imageRef} --namespace=${namespace}"
            }

            stage('Rollout') {
                sh "kubectl rollout status deployment/${deployment} --namespace=${namespace} --timeout=300s"
            }
        }
    }
}