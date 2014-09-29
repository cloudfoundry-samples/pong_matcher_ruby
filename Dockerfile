# DOCKER-VERSION 1.2.0

FROM    camelpunch/pong-matcher-base-ruby

# install app as unprivileged user
USER    web
COPY    app pong_matcher_ruby
RUN     cd pong_matcher_ruby; bundle

# run tests as part of build - should fail if tests fail
RUN     redis-server & cd pong_matcher_ruby; rake

# set up CF endpoint
RUN     cf api https://api.run.pivotal.io
