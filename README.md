# philote.rb

This is a helper library for [Philote](https://github.com/13Floor/philote), a [Redis](http://redis.io)-powered websockets server.

You don't really need this library: philote takes configuration from the Redis database it uses, so you are perfectly capable of create philote access tokens yourself and storing them in redis, however, this library makes it easier for you to do so.

## Early Stages

This library is still on very early stages, it does something extremely simple so bugs are generally not expected, but functionality like subscribing to channels and reacting to incoming messages is not yet implemented, if you use Philote for anything and feel like contributing that would be a great way to do it. :)


## Usage

### Redis Connection

By default, Philote connects to Redis using the `REDIS_URL` environment variable if you want to connect in a different way you can specify the redis client in code when you initialize your application.

```ruby

require 'redic'
require philote'

Philote.redis = Redic.new('redis://localhost:6379')
```

### Access Keys

In order to connect to Philote, a websocket client will need an [access key](https://github.com/pote/philote#access-keys), you can create them via `Philote::AccessKey#create`, here's the method signature:

```ruby
class AccessKey
    # read:
    #   an array of channel names the key user will be subscribed to.
    #
    # write:
    #   an array of channel names the key user will be able to write to.
    #
    # allowed_uses:
    #   the ammount of times a new websocket client will be able to authenticate
    #   using this access key.
    #
    # uses:
    #   the ammount of times a new websocket client has authenticated using this
    #   access key.
    #
    # token:
    #   the redis identifier.
    #
    def initialize(read: [], write: [], allowed_uses: 1, uses: 0, token: nil)
      # ...
    end
end
```

After you create an access key, a client will be able to authenticate in the Philote server running on the same Redis instance, `Philote::AccessKey#token` will contain the identifier, on a regular browser javascript use case you'll render your view with access to this token.

### Publishing Messages

As Philote uses Redis PUB/SUB under the hood, as long as your Ruby code has access to the same Redis instance you can publish messages to the websocket channels simply by publishing those messages to Redis, this library provides a helper method to do that.

```ruby
Philote.publish('channel-name', 'data')
```

## Run the test suite

Here's how to set up the local/test environment:

```bash
$ git clone git@github.com:pote/philote-rb.git && cd philote-rb
$ source .env.sample # Make sure to review the settings, as the REDIS_TEST_URL gets flushed when running the test suite.
$ make test
```
