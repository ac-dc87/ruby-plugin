#!/usr/bin/env ruby
require 'bundler/setup'
root = File.expand_path('../lib', File.dirname(__FILE__))
$: << root
require 'ruby/plugin'
require 'ruby/plugin/worker'
require 'ruby/plugin/utils/config'
require 'sneakers'
require 'sneakers/runner'
require 'sneakers/metrics/logging_metrics'
require 'logger'

# https://github.com/jondot/sneakers/wiki/Configuration
# we can implement autoscaling if need be

$config = Ruby::Plugin::Utils::Config.validate_configuration

Sneakers.configure  amqp: $config[:amqp_url],
                    threads: $config[:consumer_threads], # Threadpool size (good to match prefetch)
                    workers: $config[:consumer_workers], # Number of per-cpu processes to run
                    start_worker_delay: 0.2,
                    metrics: Sneakers::Metrics::LoggingMetrics.new,
                    timeout_job_after: 60,
                    exchange: 'esource.topic.exchange',
                    exchange_type: :topic,
                    daemonize: false,
                    log: $config[:log_output]

Sneakers.logger.level = Logger::INFO # TODO inject logger into integration file

runner = Sneakers::Runner.new([Ruby::Plugin::Worker])
runner.run
