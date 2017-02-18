#!/bin/bash

function test_mysql {
  mysqladmin -h db ping
}

count=0
# Chain tests together by using &&
until ( test_mysql )
do
  ((count++))
  if [ ${count} -gt 50 ]
  then
    echo "Services didn't become ready in time"
    exit 1
  fi
  sleep 0.5
done

echo "Services ready."
