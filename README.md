# TwitFlow

`NOTE: this is far from being ready for production. Use it at your own risk.`

Using GenStage and setup as a system of one producer, one consumer-producer and one consumer. The producer fetch tweets from the Twitter Streaming APIs and sends data to the ProducerConsumer that sends data to the Consumer:

`[A] -> [B] -> [C]`

That means:


A is only a producer (and therefore a source) B is both producer and consumer
C is only a consumer (and therefore a sink)


The producer (A) connects to the Twitter Stream API and read in all tweets sending them to the producer-consumer (B). The producer-consumer (B) will check if the hashtag appears in the tweet. If yes, it will send it to the consumer ( C ). The sink ( C ) will then log the tweet with a timestamp to the console.

The producer (A) receives messages from a continuous stream from Twitter and adds the tweets
to a `:queue`. When handling the demand from the consumers, it will pick tweets out of the queue and dispatch them.

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
export MONITOR_HASHTAG=love
mix run --no-halt

13:07:00.774 [info]  Start monitoring tweets about love

13:07:07.913 [info]  RT @lovely_zinampan: nakakainis yung teacher na nanghuhula lang ng ibibigay na grade sa estudyante

tangin*🙊😞

13:07:10.934 [info]  RT @loveloiniee: Hala paktay nagbisaya na hahahahahaha

WansaGelliInABottle BukasNa https://t.co/krwFcUoDIO

13:07:20.888 [info]  RT @PreetBharara: Some people hate this president BECAUSE they love this country https://t.co/B03e3mXKTz

13:07:22.901 [info]  RT @razalfaro: words cannot describe how beautiful you are.

I love you to death Meng..❤️
@mainedcm
#MaineForRejoice https://t.co/YgYSobzL…

13:07:28.931 [info]  RT @Bestloveporn: https://t.co/JV8b74p0w1

```

## TODO

  - tests
  - tests
  - simplify the producer logic

## Nice things, issues and possible problems

1. The producer is coupled with the Twitter API stream and this could be avoided in different ways, however, in this experiment the intention was to demonstrate how producers, producer consumers and consumers can interact with each other. So the focus was spent there.
2. The application may crash reaching the maximum rate of restarts for some of the workers, like the producer. This may be solved either isolating even more the workers and the points of failure or increasing the maximum number of restarts or using some other strategy in production.
3. Fun fact, the Twittex library pushes back-pressure at the TCP level
4. The design of the supervision tree has to be adapted after some learning on the specific domain
5. Given that now all tweets are added to a :queue, there is a risk that the queue could get too big. This may be avoided adding more consumers as the queue grows.
