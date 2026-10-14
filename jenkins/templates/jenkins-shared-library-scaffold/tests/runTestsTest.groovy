// last_verified: 2026-10-14 · Jenkins shared library scaffold
// Unit tests for runTests step

import com.lesfurets.JenkinsPipelineUnit

def suite = new JenkinsPipelineUnit()

// Mock the sh step
suite.mockStep('sh') { Map args ->
    return null
}

// Mock stage
suite.mockStep('stage') { String name, Closure body ->
    body.call()
}

// Load the step under test
def step = suite.loadStep('vars/runTests.groovy')

// Test 1: Required parameter only
step.call([imageRef: 'registry.io/app:v1'])
println "Test 1 PASSED: Required parameter only"

// Test 2: Custom test and coverage commands
step.call([
    imageRef: 'registry.io/app:v1',
    testCommand: 'pytest -v',
    coverageCommand: 'pytest --cov=app --cov-report=xml',
    envVars: [ENV: 'test', DATABASE_URL: 'sqlite:///test.db'],
    volumes: ['/host/path:/container/path'],
    workingDir: '/workspace'
])
println "Test 2 PASSED: Custom parameters"

// Test 3: Verify docker run command
suite.reset()
def capturedCmd = []
suite.mockStep('sh') { Map args ->
    capturedCmd << args.script
    return null
}

step.call([
    imageRef: 'registry.io/app:v1',
    testCommand: 'npm test',
    envVars: [NODE_ENV: 'test']
])

def runCmd = capturedCmd.find { it.contains('docker run') }
assert runCmd != null : "Docker run command not found"
assert runCmd.contains('--rm') : "Remove flag not in command"
assert runCmd.contains('-e NODE_ENV=test') : "Env var not in command"
assert runCmd.contains('-w /app') : "Working dir not in command"
assert runCmd.contains('registry.io/app:v1') : "Image ref not in command"
assert runCmd.contains('npm test') : "Test command not in command"
println "Test 3 PASSED: Docker run command correctly constructed"

println "\nAll runTests tests passed!"
return true