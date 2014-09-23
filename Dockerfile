# DOCKER-VERSION 1.2.0

FROM    ubuntu:14.04
RUN     apt-get update
RUN     apt-get install -qy build-essential wget

# chruby
ADD     https://github.com/postmodern/chruby/archive/v0.3.8.tar.gz chruby-0.3.8.tar.gz
RUN     tar -zxf chruby-0.3.8.tar.gz
RUN     cd chruby-0.3.8; make install

# ruby-install
ADD     https://github.com/postmodern/ruby-install/archive/v0.4.3.tar.gz ruby-install-0.4.3.tar.gz
RUN     tar -zxf ruby-install-0.4.3.tar.gz
RUN     cd ruby-install-0.4.3; make install

# ruby
RUN     ruby-install ruby 2.1.2

# redis
ADD     http://download.redis.io/redis-stable.tar.gz redis-stable.tar.gz
RUN     tar -zxf redis-stable.tar.gz
RUN     cd redis-stable; make install

# user
RUN     adduser --disabled-password web
USER    web
RUN     echo "source /usr/local/share/chruby/chruby.sh" >> /home/web/.profile
RUN     echo "gem: --no-document" >> /home/web/.gemrc

# install bundler
RUN     ["/bin/bash", "-cl", "chruby 2.1.2; gem install bundler"]

# install app
COPY    . pong_matcher_ruby
RUN     ["/bin/bash", "-cl", "cd pong_matcher_ruby; chruby 2.1.2; bundle"]

ENTRYPOINT ["/bin/bash", "-cl", "redis-server & cd pong_matcher_ruby; chruby 2.1.2; rake"]
