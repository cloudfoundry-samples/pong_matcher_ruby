# DOCKER-VERSION 1.2.0

FROM    camelpunch/pong-matcher-base:ruby

# install app as unprivileged user
USER    web
COPY    app pong_matcher_ruby
RUN     cd pong_matcher_ruby; bundle

# set entrypoint that runs the unit tests
ENTRYPOINT redis-server & cd pong_matcher_ruby; rake
