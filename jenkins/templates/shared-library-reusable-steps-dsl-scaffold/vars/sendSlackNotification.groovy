// last_verified: 2026-10-19
def call(Map config = [:]) {
    def channel = config.get('channel', '#general')
    def message = config.get('message', 'No message')
    echo "Sending Slack notification to ${channel}: ${message}"
}
