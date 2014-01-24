set APP_VERSION=1
IF [%1] NEQ [] (
	set APP_VERSION=%1
)
pscp -pw password -P 2222 setup_env.sh testuser@127.0.0.1:/home/testuser/
plink -t -pw password -P 2222 testuser@127.0.0.1 "sudo bash ~/setup_env.sh %APP_VERSION%"
