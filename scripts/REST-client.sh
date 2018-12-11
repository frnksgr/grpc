#!/bin/bash
curl -H "login:john" \
     -H "password:doe" \
     -X POST -d '{"message":"He said captain"}' \
     'http://localhost:7778/v1/ping'
