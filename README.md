# TwitFlow

Using GenStage and setup as a system of one producer, one consumer-producer and one consumer. The producer fetch tweets from the Twitter Streaming APIs and sends data to the ProducerConsumer that sends data to the Consumer:

`[A] -> [B] -> [C]`

That means:


A is only a producer (and therefore a source) B is both producer and consumer
C is only a consumer (and therefore a sink)


The producer (A) connects to the Twitter Stream API and read in all tweets sending them to the producer-consumer (B). The producer-consumer (B) will check if the word 'startup' appears in the tweet. If yes, it will send it to the consumer ( C ). The sink ( C ) will then log the tweet with a timestamp to the console.

## Requirements

`Elxir ~> 1.5`

## Installation

```
cd twitflow
mix deps.get
```

## Configuration

In the file `config/config.exs` you should add the following keys and secrets.
You can get them on dev.twitter.com

```
config :twittex,
  consumer_key: "",
  consumer_secret: "",
  token: "",
  token_secret: ""

```

## Run the application

In the folder of the current application run `mix run --no-halt`

## Follow a different word on twitter

By default, the application will filter only tweets that include the word 'startup'. To change this, export an environment variable called `MONITOR_HASHTAG` and give it the word or sentence you would like to follow.

Example:

```
export MONITOR_HASHTAG=bitcoin
mix run --no-halt

```

## TODO

  [] - tests

  [] - decouple the twitter stream and connection from the Producer

  [] - check if it makes sense to have the stream as GenServer and continuously sending messages to the Producer mailbox


## Nice things, issues and possible problems

1. The connection between the twitter API and the producer is not ideal, it should happen asynchronously
2. The producer is coupled with the Twitter API stream and this could be avoided in different ways, however, in this experiment the intention was to demonstrate how producers, producer consumers and consumers can interact with each other. So the focus was spent there.
3. The application may crash reaching the maximum rate of restarts for some of the workers. This may be solved either isolating even more the workers and the points of failure, increasing the maximum number of restarts or using some other strategy in production.
4. The Twittex library pushes back-pressure at the TCP level
5. The design of the supervision tree has to be adapted after some learning on the specific domain
