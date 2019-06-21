#!/usr/bin/env ruby
require 'sneakers'
require 'sneakers/runner'
require_relative '../domain/queue/queue_subscriber'

Sneakers.configure(
  amqp: ENV['AMQP_URI'],
  daemonize: false,
  log: STDOUT
)

Sneakers.logger.level = Logger::INFO

Sneakers::Runner.new([QueueSubscriber::Top10Worker, QueueSubscriber::TracksPlayed]).run