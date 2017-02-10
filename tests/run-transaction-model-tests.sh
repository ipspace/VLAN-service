#!/bin/bash
#
# Run pre-deploy unit tests
#
echo "Testing transaction model transformation"
if [ ! -f hosts ]; then
  echo ".. Cannot find Ansible inventory file hosts in current directory, aborting"
  echo 
  echo "Hint: run this script from main project directory."
  echo "Typical command would be tests/run-transaction-model-tests.sh"
  exit
fi

cd tests
export ANSIBLE_STDOUT_CALLBACK=dense
if [ -f ../../Plugins/dense.py ]; then
  export ANSIBLE_CALLBACK_PLUGINS=../../Plugins
fi

exitstatus=0
for trans in transactions/*.yml
do
  echo "Running transaction $trans"
  ansible-playbook -i ../hosts trans-model.yml -e "trans=$trans" -t validate
  if [ $? -ne 0 ]; then
    echo "  .. test failed for transaction $trans"
    exitstatus=1
  fi
done

if [ $exitstatus -ne 0 ]; then echo "Test suite failed"; fi
exit $exitstatus