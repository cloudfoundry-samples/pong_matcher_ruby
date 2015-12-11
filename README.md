# CF example app: ping-pong matching server

This is an app to match ping-pong players with each other. It's currently an
API only, so you have to use `curl` to interact with it.

It has an [acceptance test suite][acceptance-test] you might like to look at.

## Running on [Pivotal Web Services][pws]

Log in.

```bash
cf login -a https://api.run.pivotal.io
```

Target your org / space.

```bash
cf target -o myorg -s myspace
```

Sign up for a rediscloud instance.

```bash
cf create-service rediscloud 30mb redis
```

Push this app. Its manifest assumes you called your Redis instance 'redis'.

```bash
cf push -n mysubdomain
```

Export the test host

```bash
export HOST=http://mysubdomain.cfapps.io
```

Now follow the [interaction instructions][interaction].

## Running locally

The following assumes you have a working, recent version of Ruby, with bundler installed.

Install and start redis:

```bash
brew install redis
redis-server
```

In another terminal, start the application server:

```bash
bundle
PORT=3000 ruby server.rb
```

Export the test host

```bash
export HOST=http://localhost:3000
```

Now follow the [interaction instructions][interaction].

[acceptance-test]:https://github.com/cloudfoundry-samples/pong_matcher_acceptance
[pws]:https://run.pivotal.io
[interaction]:https://github.com/cloudfoundry-samples/pong_matcher_grails#interaction-instructions
