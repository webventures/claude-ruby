# Claude Ruby

[![Gem Version](https://badge.fury.io/rb/claude-ruby.svg)](https://badge.fury.io/rb/claude-ruby) [![License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![Maintainability](https://api.codeclimate.com/v1/badges/08c7e7b58e9fbe7156eb/maintainability)](https://codeclimate.com/github/webven/claude-ruby/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/08c7e7b58e9fbe7156eb/test_coverage)](https://codeclimate.com/github/webven/claude-ruby/test_coverage) [![CI](https://github.com/webven/claude-ruby/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/webven/claude-ruby/actions/workflows/ci.yml)

`claude-ruby` gem is an unofficial ruby SDK for interacting with the Anthropic API, for generating and streaming messages through Claude

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'claude-ruby'
```

And then execute:

```ruby
$ bundle install
```

Or install it yourself as:

```ruby
$ gem install claude-ruby
```

## Usage

To use this gem you'll need an API key from Anthropic, which can be obtained from the Anthropic console  
by following the Get API Access link on the [Anthropic API page](https://www.anthropic.com/api).

Set your API key as an environment variable then you can create a new `Claude::Client` instance:

```ruby
require 'claude/client'

api_key = ENV['YOUR_ANTHROPIC_API_KEY']
claude_client = Claude::Client.new(api_key)
```

## Messages

The anthropic messages endpoint allows you to: 
```
Send a structured list of input messages with text and/or image content, 
and the model will generate the next message in the conversation.
The Messages API can be used for for either single queries or stateless multi-turn conversations.
```

Using the claude-ruby gem you can call the Anthropic messages API by passing in an array of messages
where each element is a hash containing `role` and `content` properties.

The `messages` method allows converse with the Claude model in chat form. 
It requires an array of messages where each message is a hash with two properties: `role` and `content`.

`role` can be: 
- `'user'`: This represents the user's input. 
- `'assistant'`: This optional role represents the model's output.

Simple example with a single user message:

```ruby
messages = [
  {
    role: "user",
    content: "Who was the first team to win the rugby world cup?"
  }
]

response = claude_client.messages(messages)
```

The response contains a bunch of metadata and the model's message response.
To extract the message text you can you code like this:

```ruby
response['content'][0]['text']
```

You can continue the conversation by calling the `messages` method again with an expanded messages array:

```ruby

messages << {role: "assistant", content: "New Zealand won the first Rugby World Cup in 1987"}
messages << {role: "user", content: "Who came third and fourth in that competition?"}

response = claude_client.messages(messages)
puts response['content'][0]['text'] # This will give you the updated message
```

Example with a more sophisticated message structure:

```ruby
system = "Only reply in Spanish."

messages = [
  {
    role: "user",
    content: "Hi there."
  },
  {
    role: "assistant",
    content: "Hola, como estás?"
  },
  {
    role: "user",
    content: "How long does it take to fly from Auckland to Buenos Aires?"
  },
]

response = claude_client.messages(messages, {system: system})
```

For further details of the API visit https://docs.anthropic.com/claude/reference/messages_post

## Changelog

For a detailed list of changes for each version of this project, please see the [CHANGELOG](CHANGELOG.md).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/webven/claude-ruby.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Trademarks

This is an unofficial gem which has not been developed by Anthropic.  
We make no claims for the trademarks of 'Anthropic' and 'Claude', which are registered by Anthropic PBC. 