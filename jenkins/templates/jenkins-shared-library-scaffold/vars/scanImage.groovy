// last_verified: 2026-10-14 · Jenkins shared library scaffold
// Runs security scans on a Docker image using Trivy and returns results.

def call(Map config = [:]) {
    def imageRef = config.imageRef ?: (error 'imageRef is required')
    def severity = config.severity ?: 'HIGH,CRITICAL'
    def exitCode = config.exitCode ?: 1
    def format = config.format ?: 'table'
    def output = config.output
    def ignoreUnfixed = config.ignoreUnfixed ?: false

    def ignoreUnfixedFlag = ignoreUnfixed ? '--ignore-unfixed' : ''

    stage('Security Scan') {
        def trivyCmd = "trivy image --severity ${severity} ${ignoreUnfixedFlag} --format ${format} ${imageRef}"
        if (output) {
            trivyCmd += " --output ${output}"
        }
        sh """
            ${trivyCmd} || (echo "Trivy scan found vulnerabilities" && exit ${exitCode})
        """
    }
}