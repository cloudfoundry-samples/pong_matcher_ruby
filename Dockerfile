# DOCKER-VERSION 1.2.0

FROM    ubuntu:14.04
RUN     apt-get update
RUN     apt-get install -qy build-essential wget

# ruby-install
ADD     https://github.com/postmodern/ruby-install/archive/v0.4.3.tar.gz ruby-install-0.4.3.tar.gz
RUN     tar -zxf ruby-install-0.4.3.tar.gz
RUN     cd ruby-install-0.4.3; make install

# ruby
RUN     ruby-install ruby 2.1.2 -- --disable-install-doc

# redis
ADD     http://download.redis.io/redis-stable.tar.gz redis-stable.tar.gz
RUN     tar -zxf redis-stable.tar.gz
RUN     cd redis-stable; make install

# user
RUN     adduser --disabled-password web
RUN     chown -R web:web /opt/rubies/ruby-2.1.2
USER    web
ENV     PATH /opt/rubies/ruby-2.1.2/bin:$PATH
RUN     echo "gem: --no-document" >> /home/web/.gemrc

# install bundler
RUN     gem install bundler

# install app
COPY    . pong_matcher_ruby
RUN     cd pong_matcher_ruby; bundle

ENTRYPOINT redis-server & cd pong_matcher_ruby; rake
