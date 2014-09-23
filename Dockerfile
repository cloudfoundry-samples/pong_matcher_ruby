# DOCKER-VERSION 1.2.0

FROM    docker.gocd.cf-app.com:5000/pongbaseruby

# install app as unprivileged user
USER    web
COPY    . pong_matcher_ruby
RUN     cd pong_matcher_ruby; bundle

# set entrypoint that runs the unit tests
ENTRYPOINT redis-server & cd pong_matcher_ruby; rake
