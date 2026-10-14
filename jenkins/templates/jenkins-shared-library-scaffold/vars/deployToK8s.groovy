// last_verified: 2026-10-14 · Jenkins shared library scaffold
// Patches a Kubernetes Deployment image and waits for the rollout to complete.

def call(Map config = [:]) {
    def imageRef = config.imageRef ?: (error 'imageRef is required')
    def namespace = config.namespace ?: 'default'
    def deployment = config.deployment ?: (error 'deployment is required')
    def kubeconfigId = config.kubeconfigId ?: 'kubeconfig-credentials-id'
    def timeout = config.timeout ?: '300s'
    def container = config.container ?: 'app'
    def strategy = config.strategy ?: 'rolling'

    stage('Configure kubeconfig') {
        withKubeCredentials([kubeConfig: kubeconfigId]) {
            stage('Set image') {
                sh "kubectl set image deployment/${deployment} ${container}=${imageRef} --namespace=${namespace}"
            }

            if (strategy == 'rolling') {
                stage('Rollout') {
                    sh "kubectl rollout status deployment/${deployment} --namespace=${namespace} --timeout=${timeout}"
                }
            } else if (strategy == 'blue-green') {
                stage('Blue-Green Deploy') {
                    def greenDeployment = "${deployment}-green"
                    sh """
                        kubectl patch deployment ${greenDeployment} -p '{"spec":{"template":{"spec":{"containers":[{"name":"${container}","image":"${imageRef}"}]}}}}' --namespace=${namespace}
                        kubectl rollout status deployment/${greenDeployment} --namespace=${namespace} --timeout=${timeout}
                        kubectl patch service ${deployment} -p '{"spec":{"selector":{"version":"green"}}}' --namespace=${namespace}
                    """
                }
            } else if (strategy == 'canary') {
                stage('Canary Deploy') {
                    def canaryWeight = config.canaryWeight ?: 10
                    sh """
                        kubectl set image deployment/${deployment}-canary ${container}=${imageRef} --namespace=${namespace}
                        kubectl rollout status deployment/${deployment}-canary --namespace=${namespace} --timeout=${timeout}
                        kubectl patch service ${deployment} -p '{"spec":{"selector":{"version":"canary"}}}' --namespace=${namespace}
                    """
                }
            }
        }
    }
}