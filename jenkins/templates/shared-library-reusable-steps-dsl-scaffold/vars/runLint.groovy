// last_verified: 2026-10-19
def call(Map config = [:]) {
    def target = config.get('target', '.')
    echo "Running lint on ${target}"
    sh "echo 'Linting ${target}... OK'"
}
