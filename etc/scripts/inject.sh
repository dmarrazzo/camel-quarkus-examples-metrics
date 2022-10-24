#!/usr/bin/bash

echo '{ "type": "counter", "name": "foo" }' | kcat -b localhost:9092  -t metrics -P