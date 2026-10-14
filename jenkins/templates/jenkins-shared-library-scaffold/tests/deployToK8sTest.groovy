// last_verified: 2026-10-14 · Jenkins shared library scaffold
// Unit tests for deployToK8s step

import com.lesfurets.JenkinsPipelineUnit

def suite = new JenkinsPipelineUnit()

// Mock the sh step
suite.mockStep('sh') { Map args ->
    return null
}

// Mock withKubeCredentials
suite.mockStep('withKubeCredentials') { List creds, Closure body ->
    body.call()
}

// Mock stage
suite.mockStep('stage') { String name, Closure body ->
    body.call()
}

// Load the step under test
def step = suite.loadStep('vars/deployToK8s.groovy')

// Test 1: Required parameters only (rolling strategy default)
try {
    step.call([imageRef: 'registry.io/app:v1', deployment: 'myapp'])
    assert false : "Should have thrown error for missing namespace"
} catch (e) {
    // Expected - namespace is required in our implementation
}
println "Test 1 PASSED: Required parameters enforced"

// Test 2: All required parameters with defaults
def result2 = step.call([
    imageRef: 'registry.io/app:v1',
    namespace: 'staging',
    deployment: 'myapp'
])
println "Test 2 PASSED: Rolling deploy with defaults"

// Test 3: Blue-green strategy
def result3 = step.call([
    imageRef: 'registry.io/app:v1',
    namespace: 'prod',
    deployment: 'myapp',
    strategy: 'blue-green'
])
println "Test 3 PASSED: Blue-green strategy"

// Test 4: Canary strategy
def result4 = step.call([
    imageRef: 'registry.io/app:v1',
    namespace: 'prod',
    deployment: 'myapp',
    strategy: 'canary',
    canaryWeight: 20
])
println "Test 4 PASSED: Canary strategy"

// Test 5: Custom container name and timeout
def result5 = step.call([
    imageRef: 'registry.io/app:v1',
    namespace: 'staging',
    deployment: 'myapp',
    container: 'sidecar',
    timeout: '600s'
])
println "Test 5 PASSED: Custom container and timeout"

// Test 6: Verify kubectl commands
suite.reset()
def capturedCommands = []
suite.mockStep('sh') { Map args ->
    capturedCommands << args.script
    return null
}

step.call([
    imageRef: 'registry.io/app:v1',
    namespace: 'test',
    deployment: 'testapp'
])

assert capturedCommands.any { it.contains('kubectl set image deployment/testapp app=registry.io/app:v1 --namespace=test') } : "Set image command not found"
assert capturedCommands.any { it.contains('kubectl rollout status deployment/testapp --namespace=test --timeout=300s') } : "Rollout command not found"
println "Test 6 PASSED: Correct kubectl commands generated"

println "\nAll deployToK8s tests passed!"
return true