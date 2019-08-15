# Ruby::Plugin

This code was built to support variety of connectors to support 3rd party integration interoperability for S6.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ruby-plugin'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ruby-plugin

## Usage

Plugin will let you know which environment variables you need to set in order to be able to run it. Here is sample environment configuration:

    export AMQP_URL='amqp://guest:guest@localhost:5672'
    export INTEGRATION='prism_edc'
    export PRISM_TOOLKIT_URL='https://esource.nextrials.com/esource-toolkit'
    export INTEGRATION_QUEUE_NAME='custom.nextrials.cprism'

You can run the plugin using `bin/ruby-plugin` or using `foreman start`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ac-dc87/ruby-plugin. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

Put your Ruby code in the file `lib/ruby/plugin`. To experiment with that code, run `bin/console` for an interactive prompt.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Ruby::Plugin project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/ruby-plugin/blob/master/CODE_OF_CONDUCT.md).
