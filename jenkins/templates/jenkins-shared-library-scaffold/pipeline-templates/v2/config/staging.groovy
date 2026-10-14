// last_verified: 2026-10-14 · Jenkins shared library scaffold
// Staging environment configuration

return [
    namespace: 'staging',
    deployment: 'myapp-staging',
    strategy: 'rolling',
    timeout: '300s',
    container: 'app',
    // Additional staging-specific settings
    replicas: 2,
    resources: [
        requests: [cpu: '100m', memory: '128Mi'],
        limits: [cpu: '500m', memory: '512Mi']
    ]
]