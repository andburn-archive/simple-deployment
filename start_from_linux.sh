scp -P 2222 setup_env.sh testuser@127.0.0.1:~
ssh -t -p 2222 testuser@127.0.0.1 'sudo bash ~/setup_env.sh'
