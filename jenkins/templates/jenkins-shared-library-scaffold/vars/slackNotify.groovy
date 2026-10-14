// last_verified: 2026-10-14 · Jenkins shared library scaffold
// Sends a Slack notification with build status.

def call(Map config = [:]) {
    def webhookId = config.webhookId ?: 'slack-webhook-id'
    def status = config.status ?: currentBuild.result ?: 'SUCCESS'
    def message = config.message ?: "Build ${env.BUILD_NUMBER} ${status}"
    def channel = config.channel
    def username = config.username ?: 'Jenkins'
    def iconEmoji = config.iconEmoji ?: ':jenkins:'

    def color = status == 'SUCCESS' ? 'good' : status == 'UNSTABLE' ? 'warning' : 'danger'

    stage('Notify') {
        withCredentials([string(credentialsId: webhookId, variable: 'SLACK_WEBHOOK')]) {
            def payload = """
                {
                    "username": "${username}",
                    "icon_emoji": "${iconEmoji}",
                    "attachments": [
                        {
                            "color": "${color}",
                            "text": "${message}",
                            "fields": [
                                {"title": "Build", "value": "${env.BUILD_NUMBER}", "short": true},
                                {"title": "Status", "value": "${status}", "short": true},
                                {"title": "Branch", "value": "${env.BRANCH_NAME ?: 'N/A'}", "short": true},
                                {"title": "Commit", "value": "${env.GIT_COMMIT?.substring(0, 7) ?: 'N/A'}", "short": true}
                            ],
                            "footer": "Jenkins Shared Library",
                            "ts": ${System.currentTimeMillis() / 1000}
                        }
                    ]
                }
            """.stripIndent().trim()

            if (channel) {
                payload = payload.replace('"attachments": [', '"channel": "' + channel + '", "attachments": [')
            }

            sh """
                curl -X POST -H 'Content-type: application/json' --data '${payload}' \${SLACK_WEBHOOK}
            """
        }
    }
}