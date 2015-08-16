#!/usr/bin/env bash

# This is a test with one or more asserts
testSampleScriptParameters() {
  # Load sample_script.sh for testing
  . sample_script.sh

  echo "Executing 3 Asserts..."

  assertTrue 'Check default DEMO_PATH' "[ '${DEMO_PATH}' == '/bin/bash' ]"
  assertTrue 'Check valid DEMO_INT values' "[ $DEMO_INT -ge 0 -a $DEMO_INT -le 2 ]"
  assertTrue 'Check that DEMO_ARRAY is not empty' "[ ${#DEMO_ARRAY[@]} -ne 0 ]"
}



# Execute shunit2 to run the tests
. shunit2-2.1.6/src/shunit2