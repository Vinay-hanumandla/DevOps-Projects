// last_verified: 2026-10-14 · Jenkins shared library scaffold
// Runs unit and integration tests inside a container.

def call(Map config = [:]) {
    def imageRef = config.imageRef ?: (error 'imageRef is required')
    def testCommand = config.testCommand ?: 'npm test'
    def coverageCommand = config.coverageCommand
    def envVars = config.envVars ?: [:]
    def volumes = config.volumes ?: []
    def workingDir = config.workingDir ?: '/app'

    def envStr = envVars.collect { "-e ${it.key}=${it.value}" }.join(' ')
    def volumeStr = volumes.collect { "-v ${it}" }.join(' ')

    stage('Unit Tests') {
        sh """
            docker run --rm ${envStr} ${volumeStr} -w ${workingDir} ${imageRef} ${testCommand}
        """
    }

    if (coverageCommand) {
        stage('Coverage') {
            sh """
                docker run --rm ${envStr} ${volumeStr} -w ${workingDir} ${imageRef} ${coverageCommand}
            """
        }
    }
}