// last_verified: 2026-10-14 · Jenkins shared library scaffold
// Unit tests for checkoutAndLint step

import com.lesfurets.JenkinsPipelineUnit

def suite = new JenkinsPipelineUnit()

// Mock the checkout step
suite.mockStep('checkout') { Map args ->
    return null
}

// Mock the sh step
suite.mockStep('sh') { Map args ->
    if (args.script.contains('git rev-parse')) {
        return 'abc123def456'
    }
    return null
}

// Mock stage
suite.mockStep('stage') { String name, Closure body ->
    body.call()
}

// Load the step under test
def step = suite.loadStep('vars/checkoutAndLint.groovy')

// Test 1: Default parameters
def result1 = step.call([:])
assert result1 == 'abc123def456' : "Expected revision 'abc123def456', got '${result1}'"
println "Test 1 PASSED: Default parameters"

// Test 2: Custom parameters
def result2 = step.call([
    repoUrl: 'https://github.com/custom/repo.git',
    branch: 'develop',
    credentialsId: 'custom-creds',
    lintCommand: 'make lint'
])
assert result2 == 'abc123def456' : "Expected revision 'abc123def456', got '${result2}'"
println "Test 2 PASSED: Custom parameters"

// Test 3: Verify checkout was called with correct params
suite.reset()
def capturedCheckoutArgs = []
suite.mockStep('checkout') { Map args ->
    capturedCheckoutArgs = args
    return null
}

step.call([branch: 'feature/test'])
assert capturedCheckoutArgs.branches[0].name == '*/feature/test' : "Branch not passed correctly"
println "Test 3 PASSED: Branch parameter passed to checkout"

println "\nAll checkoutAndLint tests passed!"
return true