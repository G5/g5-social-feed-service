#!/bin/bash
set -e

echo " -- bundle exec rake environment -- "
bundle exec rake environment

bundle exec rspec spec
