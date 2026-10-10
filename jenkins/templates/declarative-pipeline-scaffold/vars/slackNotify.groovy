// last_verified: 2026-10-10 · Jenkins shared library
// Sends a formatted Slack notification via incoming webhook.

def call(Map params) {
    def webhookId = params.webhookId ?: 'slack-webhook-id'
    def status = params.status ?: 'SUCCESS'
    def message = params.message ?: "Build ${env.BUILD_NUMBER} ${status}"
    def channel = params.channel
    def username = params.username ?: 'Jenkins'
    def iconEmoji = params.iconEmoji ?: ':jenkins:'

    def color = switch (status) {
        case 'SUCCESS' -> '#36a64f'
        case 'UNSTABLE' -> '#ffcc00'
        case 'FAILURE' -> '#ff0000'
        case 'ABORTED' -> '#808080'
        default -> '#439FE0'
    }

    def payload = [
        username: username,
        icon_emoji: iconEmoji,
        attachments: [[
            color: color,
            text: message,
            fields: [
                [title: 'Job', value: env.JOB_NAME, short: true],
                [title: 'Build', value: "#${env.BUILD_NUMBER}", short: true],
                [title: 'Branch', value: env.BRANCH_NAME ?: 'N/A', short: true],
                [title: 'Commit', value: env.GIT_COMMIT?.take(7) ?: 'N/A', short: true],
                [title: 'Status', value: status, short: true],
                [title: 'URL', value: env.BUILD_URL, short: true]
            ],
            ts: (System.currentTimeMillis() / 1000).intValue()
        ]]
    ]

    if (channel) {
        payload.channel = channel
    }

    withCredentials([string(credentialsId: webhookId, variable: 'SLACK_WEBHOOK_URL')]) {
        sh """
            curl -X POST -H 'Content-type: application/json' \\
                --data '\${payload}' \\
                "\${SLACK_WEBHOOK_URL}"
        """
    }
}