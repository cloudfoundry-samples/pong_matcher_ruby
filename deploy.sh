#!/bin/bash

set -xe

docker run -t camelpunch/pong-matcher-ruby /bin/bash -c "\
    cd pong_matcher_ruby
    cf auth $CF_USERNAME $CF_PASSWORD &&
    cf target -o $CF_ORG -s $CF_SPACE &&
    cf push -n $HOSTNAME -d cfapps.io -n rubypong"
