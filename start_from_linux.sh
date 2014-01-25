BUILD_USER="vagrant"
APP_VERSION=1
if [ -n "$1" ] ; then
	APP_VERSION=$1
fi
scp -P 2222 setup_env.sh $BUILD_USER@127.0.0.1:~
ssh -t -p 2222 $BUILD_USER@127.0.0.1 "sudo bash ~/setup_env.sh $APP_VERSION $2"
