#!/bin/bash
set -e

# service mysql start

# sleep 10
./ci/test-rails/wait-on-linked-services.sh

# mysql -e "CREATE DATABASE gts_test"
# mysql -u root -e "create database gts_test"
echo " -- bundle exec rake db:create_g5_test_schema -- "
bundle exec rake db:create_g5_test_schema

echo " -- bundle exec rake db:add_google_customers -- "
bundle exec rake db:add_google_customers

echo " -- bundle exec rake environment -- "
bundle exec rake environment

echo " -- DATE=2012-01-01 bundle exec rake gts:adwords:download -- "

DATE=2012-01-01 bundle exec rake gts:adwords:download
echo " -- START_DATE=2012-01-01 END_DATE=2012-01-31 bundle exec rake gts:adwords:download_range -- "

START_DATE=2012-01-01 END_DATE=2012-01-31 bundle exec rake gts:adwords:download_range
echo " -- START_DATE=2012-01-01 END_DATE=2012-01-31 CLIENT_ID=1234 bundle exec bundle exec rake gts:adwords:download_client_range -- "

START_DATE=2012-01-01 END_DATE=2012-01-31 CLIENT_ID=1234 bundle exec bundle exec rake gts:adwords:download_client_range
echo " -- bundle exec rake gts:ga_download -- "

bundle exec rake gts:ga_download
echo " -- bundle exec rake gts:spec -- "

bundle exec rake gts:spec
echo " -- DONE -- "
