#!/usr/bin/bash

curl -XGET -s http://localhost:9988/q/metrics | grep foo
