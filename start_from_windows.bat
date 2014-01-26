set BUILD_USER="testuser"
set PASS="password"

set APP_VERSION=1
IF [%1] NEQ [] (
	set APP_VERSION=%1
)

set CLEAN_INSTALL=1
IF [%2] NEQ [] (
	set CLEAN_INSTALL=%2
)

REM Assume Putty is installed and in path
pscp -pw %PASS% -P 2222 setup_env.sh %BUILD_USER%@127.0.0.1:/home/%BUILD_USER%/
plink -t -pw %PASS% -P 2222 %BUILD_USER%@127.0.0.1 "sudo bash ~/setup_env.sh %APP_VERSION% %CLEAN_INSTALL%"
