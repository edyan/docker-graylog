#!/bin/bash

set -e

GREEN='\033[0;32m'
NC='\033[0m' # No Color

docker build -t edyan_graylog_test .

echo ""
echo -e "${GREEN}Testing ${NC}"
cd tests
export GOSS_SLEEP=45
export GOSS_FILES_STRATEGY=cp
dgoss run edyan_graylog_test
