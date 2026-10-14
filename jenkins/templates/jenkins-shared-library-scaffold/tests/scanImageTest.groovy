// last_verified: 2026-10-14 · Jenkins shared library scaffold
// Unit tests for scanImage step

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
def step = suite.loadStep('vars/scanImage.groovy')

// Test 1: Required parameter only
step.call([imageRef: 'registry.io/app:v1'])
println "Test 1 PASSED: Required parameter only"

// Test 2: Custom severity and format
step.call([
    imageRef: 'registry.io/app:v1',
    severity: 'CRITICAL',
    format: 'json',
    output: 'trivy-report.json',
    ignoreUnfixed: true,
    exitCode: 0
])
println "Test 2 PASSED: Custom parameters"

// Test 3: Verify trivy command construction
suite.reset()
def capturedCmd = []
suite.mockStep('sh') { Map args ->
    capturedCmd << args.script
    return null
}

step.call([
    imageRef: 'registry.io/app:v1',
    severity: 'HIGH,CRITICAL',
    format: 'table'
])

def trivyCmd = capturedCmd.find { it.contains('trivy image') }
assert trivyCmd != null : "Trivy command not found"
assert trivyCmd.contains('--severity HIGH,CRITICAL') : "Severity not in command"
assert trivyCmd.contains('--format table') : "Format not in command"
assert trivyCmd.contains('registry.io/app:v1') : "Image ref not in command"
println "Test 3 PASSED: Trivy command correctly constructed"

println "\nAll scanImage tests passed!"
return true