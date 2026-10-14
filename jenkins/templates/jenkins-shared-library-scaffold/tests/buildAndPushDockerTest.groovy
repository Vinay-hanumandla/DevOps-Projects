// last_verified: 2026-10-14 · Jenkins shared library scaffold
// Unit tests for buildAndPushDocker step

import com.lesfurets.JenkinsPipelineUnit

def suite = new JenkinsPipelineUnit()

// Mock the sh step
suite.mockStep('sh') { Map args ->
    if (args.script.contains('docker build')) {
        return null
    }
    if (args.script.contains('docker login')) {
        return null
    }
    if (args.script.contains('docker push')) {
        return null
    }
    return null
}

// Mock withCredentials
suite.mockStep('withCredentials') { List creds, Closure body ->
    body.call()
}

// Mock stage
suite.mockStep('stage') { String name, Closure body ->
    body.call()
}

// Load the step under test
def step = suite.loadStep('vars/buildAndPushDocker.groovy')

// Test 1: Default parameters
def result1 = step.call([:])
assert result1 == 'registry.example.com/app:latest' : "Expected 'registry.example.com/app:latest', got '${result1}'"
println "Test 1 PASSED: Default parameters"

// Test 2: Custom parameters
def result2 = step.call([
    image: 'myapp',
    tag: 'v1.0.0',
    registry: 'myregistry.io',
    credentialsId: 'my-creds',
    dockerfile: 'Dockerfile.prod',
    buildArgs: [VERSION: '1.0.0', BUILD_DATE: '2026-10-14'],
    context: './app',
    target: 'production',
    platform: 'linux/amd64'
])
assert result2 == 'myregistry.io/myapp:v1.0.0' : "Expected 'myregistry.io/myapp:v1.0.0', got '${result2}'"
println "Test 2 PASSED: Custom parameters with build args"

// Test 3: Verify docker build command includes build args
suite.reset()
def capturedBuildCmd = []
suite.mockStep('sh') { Map args ->
    if (args.script.contains('docker build')) {
        capturedBuildCmd = args.script
    }
    return null
}

step.call([
    image: 'testapp',
    tag: 'test',
    registry: 'test.io',
    buildArgs: [ARG1: 'val1', ARG2: 'val2']
])

assert capturedBuildCmd.contains('--build-arg ARG1=val1') : "Build arg ARG1 not found"
assert capturedBuildCmd.contains('--build-arg ARG2=val2') : "Build arg ARG2 not found"
assert capturedBuildCmd.contains('--target') == false : "Target should not be in default call"
println "Test 3 PASSED: Build args correctly passed to docker build"

println "\nAll buildAndPushDocker tests passed!"
return true