// last_verified: 2026-10-10 · Jenkins shared library
// Patches a Kubernetes Deployment image and waits for rollout to complete.

def call(Map params) {
    def imageRef = params.imageRef ?: (error 'imageRef is required')
    def namespace = params.namespace ?: 'default'
    def deployment = params.deployment ?: 'app'
    def kubeconfigId = params.kubeconfigId ?: 'kubeconfig-credentials-id'
    def timeout = params.timeout ?: '300s'
    def container = params.container ?: 'app'

    stage("Configure kubeconfig (${namespace})") {
        withKubeCredentials([kubeConfig: kubeconfigId]) {
            stage("Set image on ${deployment}") {
                sh "kubectl set image deployment/${deployment} ${container}=${imageRef} --namespace=${namespace} --record"
            }

            stage("Wait for rollout (${timeout})") {
                sh "kubectl rollout status deployment/${deployment} --namespace=${namespace} --timeout=${timeout}"
            }
        }
    }
}