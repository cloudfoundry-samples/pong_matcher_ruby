# CF example app: ping-pong matching server

This is an app to match ping-pong players with each other. It's currently an
API only, so you have to use `curl` to interact with it.

It has an [acceptance test suite][acceptance-test] you might like to look at.

## Getting matched

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

In another terminal, start by clearing the database from any previous tests.
You should get a 200.

```bash
curl -v -X DELETE http://localhost:3000/all
```

Then request a match, providing both a request ID and player ID. Again, you
should get a 200.

```bash
curl -v -X PUT http://localhost:3000/match_requests/firstrequest -d '{"player": "andrew"}'
```

Now pretend to be someone else requesting a match:

```bash
curl -v -X PUT http://localhost:3000/match_requests/secondrequest -d '{"player": "navratilova"}'
```

Let's check on the status of our first match request:

```bash
curl -v -X GET http://localhost:3000/match_requests/firstrequest
```

The bottom of the output should show you the match_id. You'll need this in the
next step.

Now pretend that you've got back to your desk and need to enter the result:

```bash
curl -v -X POST http://localhost:3000/results -d '
{
    "match_id":"thematchidyoureceived",
    "winner":"andrew",
    "loser":"navratilova"
}'
```

You should get a 201 Created response.

Future requests with different player IDs should not cause a match with someone
who has already played. The program is not yet useful enough to go back and
allow people who've already played to play again.

[acceptance-test]:https://github.com/camelpunch/pong_matcher_acceptance
