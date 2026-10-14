// last_verified: 2026-10-14 · Jenkins shared library scaffold
// Unit tests for slackNotify step

import com.lesfurets.JenkinsPipelineUnit

def suite = new JenkinsPipelineUnit()

// Mock the sh step
suite.mockStep('sh') { Map args ->
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

// Mock currentBuild
def currentBuild = [result: 'SUCCESS', number: 42]
suite.bindVariable('currentBuild', currentBuild)

// Mock env
def env = [BUILD_NUMBER: '42', BRANCH_NAME: 'main', GIT_COMMIT: 'abc123def']
suite.bindVariable('env', env)

// Load the step under test
def step = suite.loadStep('vars/slackNotify.groovy')

// Test 1: Default parameters
step.call([:])
println "Test 1 PASSED: Default parameters"

// Test 2: Custom parameters
step.call([
    webhookId: 'my-webhook',
    status: 'FAILURE',
    message: 'Build failed!',
    channel: '#alerts',
    username: 'CI Bot',
    iconEmoji: ':rocket:'
])
println "Test 2 PASSED: Custom parameters"

// Test 3: Verify curl command construction
suite.reset()
def capturedCmd = []
suite.mockStep('sh') { Map args ->
    capturedCmd << args.script
    return null
}

step.call([
    status: 'SUCCESS',
    message: 'Build passed!'
])

def curlCmd = capturedCmd.find { it.contains('curl') }
assert curlCmd != null : "Curl command not found"
assert curlCmd.contains('"color": "good"') : "Success color not in payload"
assert curlCmd.contains('Build 42 SUCCESS') : "Message not in payload"
assert curlCmd.contains('"title": "Build"') : "Build field not in payload"
assert curlCmd.contains('"title": "Status"') : "Status field not in payload"
println "Test 3 PASSED: Slack payload correctly constructed"

// Test 4: Failure color
suite.reset()
capturedCmd = []
suite.mockStep('sh') { Map args ->
    capturedCmd << args.script
    return null
}

step.call([status: 'FAILURE'])

curlCmd = capturedCmd.find { it.contains('curl') }
assert curlCmd.contains('"color": "danger"') : "Failure color not in payload"
println "Test 4 PASSED: Failure color correct"

println "\nAll slackNotify tests passed!"
return true