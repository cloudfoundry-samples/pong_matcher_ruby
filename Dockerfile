# DOCKER-VERSION 1.2.0

FROM    docker.gocd.cf-app.com:5000/pongbase

# ruby-install
ADD     https://github.com/postmodern/ruby-install/archive/v0.4.3.tar.gz ruby-install-0.4.3.tar.gz
RUN     tar -zxf ruby-install-0.4.3.tar.gz
RUN     cd ruby-install-0.4.3; make install

# ruby
RUN     ruby-install ruby 2.1.2 -- --disable-install-doc
RUN     chown -R web:web /opt/rubies/ruby-2.1.2

# install app as unprivileged user
USER    web
ENV     PATH /opt/rubies/ruby-2.1.2/bin:$PATH
RUN     echo "gem: --no-document" >> /home/web/.gemrc
RUN     gem install bundler
COPY    . pong_matcher_ruby
RUN     cd pong_matcher_ruby; bundle

# set entrypoint that runs the unit tests
ENTRYPOINT redis-server & cd pong_matcher_ruby; rake
