# Claude Ruby

[![Gem Version](https://badge.fury.io/rb/claude-ruby.svg)](https://badge.fury.io/rb/claude-ruby) [![License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![Maintainability](https://api.codeclimate.com/v1/badges/08c7e7b58e9fbe7156eb/maintainability)](https://codeclimate.com/github/webventures/claude-ruby/maintainability) [![CI](https://github.com/webventures/claude-ruby/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/webventures/claude-ruby/actions/workflows/ci.yml)

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
messages = claude_client.user_message("Who was the first team to win the rugby world cup?")
response = claude_client.messages(messages)
```

The response contains a bunch of metadata and the model's message response.
To extract the message text you can use:

```ruby
claude_client.parse_response(response)
```

Or parse the response yourself:

```ruby
response['content'][0]['text']
```

```claude_client.user_message``` is just for simple user messages. For more complex messages you can specify the payload in detail:

```ruby
messages = [
  {
    role: "user",
    content: "In which year was the first ever rugby world cup? (A) 1983 (B) 1987 (C) 1991"
  },
  {
    role: "assistant",
    content: "The best answer is ("
  }
]

response = claude_client.messages(messages)
```


You can continue the conversation by calling the `messages` method again with an expanded messages array:

```ruby

messages = [{ role: "user", content: "Who was the first team to win the rugby world cup?" }]
messages << { role: "assistant", content: "New Zealand won the first Rugby World Cup in 1987" }
messages << { role: "user", content: "Who came third and fourth in that competition?" }

response = claude_client.messages(messages)
puts claude_client.parse_response(response) # This will give you the updated message
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

response = claude_client.messages(messages, { system: system })
```

## Models

If you don't specify a model, then the gem will use the latest version of Claude Sonnet by default, which is currently ```claude-3-5-sonnet-20240620```

You can use a different model by specifying it as a parameter in the messages call:

```ruby
response = claude_client.messages(messages, { model: 'claude-3-haiku-20240307' })
````

There are some constants defined so you can choose an appropriate model for your use-case and not have to worry about updating it when new Claude models are released:

```ruby
Claude::Model::CLAUDE_OPUS_LATEST
Claude::Model::CLAUDE_SONNET_LATEST
Claude::Model::CLAUDE_HAIKU_LATEST

Claude::Model::CLAUDE_FASTEST
Claude::Model::CLAUDE_CHEAPEST
Claude::Model::CLAUDE_BALANCED
Claude::Model::CLAUDE_SMARTEST
````

Example usage:

```ruby
response = claude_client.messages(messages, { model: Claude::Model::CLAUDE_CHEAPEST })
````

## Timeout

You can optionally set a timeout (integer) which will determine the maximum number of seconds to wait for the API call to complete.

There are two ways to do this:

1. Set a default timeout when instantiating the claude_client \
This timeout value will be used for all API calls unless overridden.

```ruby
claude_client = Claude::Client.new(api_key, timeout: 10)
```

2. Pass in a timeout value as a parameter when calling the messages method. \
This timeout value will be used only for that specific messages request. 

```ruby
response = claude_client.messages(messages, { timeout: 10 })
```


## Parameters

You can pass in any of the following parameters, which will be included in the Anthropic API call: 

```ruby
model
system
max_tokens
metadata
stop_sequences
stream
temperature
top_p
top_k

timeout (*)
````
(*) timeout is used for the HTTP request but not passed with the API data

Example:

```ruby
response = claude_client.messages(messages, 
                                  { model: Claude::Model::CLAUDE_SMARTEST,
                                    max_tokens: 500,
                                    temperature: 0.1 })
````

## Custom endpoint

By default claude-ruby will use the latest official Anthropic API endpoint at the time that the gem version is released.

You can optionally optionally override this - e.g. for testing, or for using a beta endpoint.

```ruby
claude_client = Claude::Client.new(api_key, endpoint: 'you-custom-endpoint')
```

## Vision

It's possible to pass an image to the Anthropic API and have Claude describe the image for you.
Here's an example how to do that using claude-ruby gem:

```ruby
require 'httparty'
require 'base64'

def fetch_and_encode_image(url)
  response = HTTParty.get(url)
  Base64.strict_encode64(response.body)
end

image_url = "https://images.unsplash.com/photo-1719630668118-fb27d922b165?ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&fm=jpg&fit=crop&w=1080&q=80&fit=max"
messages = [
    {
        "role": "user",
        "content": [
            {
                "type": "image",
                "source": {
                    "type": "base64",
                    "media_type": "image/jpeg",
                    "data": fetch_and_encode_image(image_url),
                },
            },
            {
                "type": "text",
                "text": "Describe this image."
            }
        ],
    }
]

response = claude_client.messages(messages)
image_description = claude_client.parse_response(response)
```

For further details of the API visit https://docs.anthropic.com/claude/reference/messages_post

## Changelog

For a detailed list of changes for each version of this project, please see the [CHANGELOG](CHANGELOG.md).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/webventures/claude-ruby.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Trademarks

This is an unofficial gem which has not been developed by Anthropic.  
We make no claims for the trademarks of 'Anthropic' and 'Claude', which are registered by Anthropic PBC. 