#!/usr/bin/bash

# import config file
source deploy.cfg
# import some external functions
source deploy_lib_helper.sh
source deploy_lib_build.sh
source deploy_lib_monitor.sh

console_message "Starting Build Process"
ls -la
