#!/bin/bash

set -ex

docker pull docker.gocd.cf-app.com:5000/pong-matcher-ruby || true
docker build $DOCKER_BUILD_OPTS -t docker.gocd.cf-app.com:5000/pong-matcher-ruby .
docker push docker.gocd.cf-app.com:5000/pong-matcher-ruby
