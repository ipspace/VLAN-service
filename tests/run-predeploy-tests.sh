#!/bin/bash
#
# Run pre-deploy unit tests
#
echo "Running pre-deploy unit tests"
if [ ! -f hosts ]; then
  echo ".. Cannot find Ansible inventory file hosts in current directory, aborting"
  echo 
  echo "Hint: run this script from main project directory."
  echo "Typical command would be tests/run-predeploy-tests.sh"
  exit
fi

echo "Running initial test (should succeed)"
ansible-playbook tests/predeploy.yml -e svcs=../tests/services/svc-pd-initial.yml >/dev/null 2>/dev/null
if [ $? -ne 0 ]; then
  echo ".. initial test failed, cannot proceed"
  exit 1
fi
echo "  .. OK, proceeding"

exitstatus=0
for svctest in tests/services/svc-pdf-*.yml
do
  echo "Running scenario $svctest"
  ansible-playbook tests/predeploy.yml -e svcs=../$svctest >/dev/null 2>/dev/null
  if [ $? -ne 0 ]; then
    echo "  .. failed as expected"
  else
    echo "  >>> DID NOT FAIL"
    exitstatus=1
  fi
done 

if [ $exitstatus -ne 0 ]; then echo "Test suite failed"; fi
exit $exitstatus