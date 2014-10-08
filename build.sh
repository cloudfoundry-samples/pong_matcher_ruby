#!/bin/bash

docker build -t docker.gocd.cf-app.com:5000/pong-matcher-ruby .
docker push docker.gocd.cf-app.com:5000/pong-matcher-ruby
