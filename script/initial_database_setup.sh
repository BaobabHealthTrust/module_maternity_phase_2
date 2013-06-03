#!/bin/bash

usage(){
  echo "Usage: $0 ENVIRONMENT SITE"
  echo
  echo "ENVIRONMENT should be: development|test|production"
  echo "Available SITES:"
  ls -1 db/data
} 

ENV=$1
SITE=$2

if [ -z "$ENV" ] || [ -z "$SITE" ] ; then
  usage
  exit
fi

set -x # turns on stacktrace mode which gives useful debug information

 if [ ! -x config/database.yml ] ; then
   cp config/database.yml.example config/database.yml
 fi
 
 if [ ! -x config/application.yml ] ; then
   cp  config/application.yml.example  config/application.yml
 fi
 
 if [ ! -x config/protocol_task_flow.yml ] ; then
   cp config/protocol_task_flow.yml.example config/protocol_task_flow.yml
 fi
 

USERNAME=`ruby -ryaml -e "puts YAML::load_file('config/database.yml')['${ENV}']['username']"`
PASSWORD=`ruby -ryaml -e "puts YAML::load_file('config/database.yml')['${ENV}']['password']"`
DATABASE=`ruby -ryaml -e "puts YAML::load_file('config/database.yml')['${ENV}']['database']"`
HOST=`ruby -ryaml -e "puts YAML::load_file('config/database.yml')['${ENV}']['host']"`

echo "DROP DATABASE $DATABASE;" | mysql --host=$HOST --user=$USERNAME --password=$PASSWORD
echo "CREATE DATABASE $DATABASE;" | mysql --host=$HOST --user=$USERNAME --password=$PASSWORD

mysql --host=$HOST --user=$USERNAME --password=$PASSWORD $DATABASE < db/core_dump.sql
mysql --host=$HOST --user=$USERNAME --password=$PASSWORD $DATABASE < db/create_dde_server_connection.sql

