#!/bin/bash 
redis-cli flushall
rake db:drop
rake db:create
rake db:migrate
rake db:seed

