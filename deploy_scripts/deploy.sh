#!/usr/bin/bash

# import config file
source deploy.cfg
# import some external functions
source deploy_lib_helper.sh
source deploy_lib_build.sh
source deploy_lib_monitor.sh

SANDBOX_DIR=$(pwd)

console_message "Checking Source Package"
# create a checksum of all files in webpackage
createChecksumFile webpackage webpackage.md5
# create a tar archive of the webpackage
tar -zcvf webpackage_preBuild.tgz webpackage

# TODO: what if /tmp/last_build.md5 doesn't exist (better location)
# compare previous build with current one
compareChecksumFiles /tmp/last_build.md5 webpackage.md5
FILECHANGE=$?
# TODO: only change on successfull deployment (i.e. reflects live package)
#cp webpackage.md5 /tmp/last_build.md5

# if there is no difference in the files do nothing and exit
if [ $FILECHANGE -eq 0 ]
then
	console_error "No change in files, doing nothing and exiting."
	exit 1
fi

# delete webpackage dir
rm -rf webpackage

#--- Start Build Process ---#

console_message "Building application"

# move preBuild archive to build folder
mv webpackage_preBuild.tgz build
cd build
# extract preBuild
tar -zxvf webpackage_preBuild.tgz
# run build perl script
perl $SANDBOX_DIR/buildapp.pl webpackage
# create preIntegrate archive
tar -zcvf ../webpackage_preIntegrate.tgz webpackage
# back up to sandbox level
cd ..
ERRORCHECK=0