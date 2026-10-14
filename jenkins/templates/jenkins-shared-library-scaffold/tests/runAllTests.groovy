// last_verified: 2026-10-14 · Jenkins shared library scaffold
// Test runner for Jenkins Pipeline Unit tests

import org.jenkinsci.test.acceptance.pipeline.PipelineStep
import com.lesfurets.JenkinsPipelineUnit

def suite = new JenkinsPipelineUnit()

// Load all test files
def testDir = new File('tests')
def testFiles = testDir.listFiles({ file -> file.name.endsWith('Test.groovy') })?.sort()

if (!testFiles) {
    println "No test files found in tests/"
    System.exit(1)
}

def totalTests = 0
def passedTests = 0
def failedTests = 0

testFiles.each { testFile ->
    println "\n=== Running ${testFile.name} ==="
    def testScript = testFile.text
    def result = suite.runScript(testScript)
    
    if (result) {
        println "PASSED: ${testFile.name}"
        passedTests++
    } else {
        println "FAILED: ${testFile.name}"
        println suite.getLastError()
        failedTests++
    }
    totalTests++
}

println "\n=== Test Summary ==="
println "Total: ${totalTests}"
println "Passed: ${passedTests}"
println "Failed: ${failedTests}"

if (failedTests > 0) {
    System.exit(1)
}