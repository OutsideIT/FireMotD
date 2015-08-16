#!/usr/bin/env bash

# This is a test with one or more asserts
testSampleScriptParameters() {
  # Load sample_script.sh for testing
  . sample_script.sh

  echo "Executing 3 Asserts..."

  # Add asserts here ...
}

function testWeCanWriteTests () {
    assertEquals "it works" "it works"
}

# Execute shunit2 to run the tests
. shunit2-2.1.6/src/shunit2