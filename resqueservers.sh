#!/bin/bash 
redis-cli shutdown
redis-server &
echo "Running Redis in background"
cd /home/deploy1/empath/current && ( RBENV_ROOT=/home/ubuntu/.rbenv/ RBENV_VERSION=2.1.1 RBENV_ROOT=/home/ubuntu/.rbenv/ RBENV_VERSION=2.1.1 /home/ubuntu/.rbenv//bin/rbenv exec bundle exec rake RAILS_ENV=production QUEUE="*" PIDFILE=./tmp/pids/resque_work_1.pid BACKGROUND=yes VERBOSE=1 INTERVAL=5 environment resque:work >> log/resque.log 2>> log/resque.log )
echo "Running all Resque workers in background"
RAILS_ENV=production bundle exec rake resque:scheduler DYNAMIC_SCHEDULE=true &
