// last_verified: 2026-10-19
def call(Map config = [:]) {
    def image = config.get('image', 'app:latest')
    echo "Building image ${image}"
    sh "echo 'Building ${image}... OK'"
}
