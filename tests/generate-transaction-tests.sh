#!/bin/bash
#
# Batch-generate correct data for transaction tests
# Use this script only when you're absolutely sure the transaction-to-node
# translational model is correct
#
cat <<EOH
This script generates 'correct' node data models used in transaction unit tests

You should run this script IF AND ONLY IF you're absolutely sure the translation
Jinja2 template works correctly and you want to store its results for future
unit tests.

EOH
while true; do
    read -p "Do you REALY REALLY want to run this script [y/n]: " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo ""
if [ ! -f hosts ]; then
  echo ".. Cannot find Ansible inventory file hosts in current directory, aborting"
  echo 
  echo "Hint: run this script from main project directory."
  echo "Typical command would be tests/generate-transaction-tests.sh"
  exit
fi

echo "Generating (hopefully) correct answers"
cd tests
export ANSIBLE_STDOUT_CALLBACK=dense
if [ -f ../../Plugins/dense.py ]; then
  export ANSIBLE_CALLBACK_PLUGINS=../../Plugins
fi

for trans in transactions/*.yml
do
  echo "Running transaction $trans"
  ansible-playbook -i ../hosts trans-model.yml -e "trans=$trans output=transactions/valid"
  if [ $? -ne 0 ]; then
    echo "  .. transaction $trans failed, aborting..."
    exit
  fi
done
