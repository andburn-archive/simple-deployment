set BUILD_USER="vagrant"
set PASS="vagrant"
set APP_VERSION=1
IF [%1] NEQ [] (
	set APP_VERSION=%1
)
pscp -pw $PASS -P 2222 setup_env.sh $BUILD_USER@127.0.0.1:/home/$BUILD_USER/
plink -t -pw $PASS -P 2222 $BUILD_USER@127.0.0.1 "sudo bash ~/setup_env.sh %APP_VERSION%"
