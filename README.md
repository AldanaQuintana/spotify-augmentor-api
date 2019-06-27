Spotify augmentor api
=====================

[Demo](http://spotify-augmentor.danacodes.tech/top-10)

# Description

This api allows you to see the top 10 of the tracks most played in real time.

# Quick Usage

Top 10 at current time

```bash
curl -X GET 'http://spotify-augmentor.danacodes.tech/top-10'
```

Top 10 of a specific moment. (Use the parameter "at")

```bash
curl -X GET 'http://spotify-augmentor.danacodes.tech/top-10?at=2019-06-26T01:20:00'
```

For more details about usage, architecture and next steps see the [wiki](https://github.com/AldanaQuintana/spotify-augmentor-api/wiki).
