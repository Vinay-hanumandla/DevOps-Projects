// last_verified: 2026-10-14 · Jenkins shared library scaffold
// Production environment configuration

return [
    namespace: 'production',
    deployment: 'myapp',
    strategy: 'blue-green',  // Options: rolling, blue-green, canary
    timeout: '600s',
    container: 'app',
    canaryWeight: 10,  // Percentage for canary (1-100)
    // Production-specific settings
    replicas: 3,
    resources: [
        requests: [cpu: '250m', memory: '256Mi'],
        limits: [cpu: '1000m', memory: '1Gi']
    ],
    // Health check endpoints
    healthPath: '/health',
    readyPath: '/ready',
    // Rollback on failure
    rollbackOnFailure: true
]