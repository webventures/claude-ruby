require 'httparty'
require 'json'

module Claude
  module Model
    CLAUDE_3_OPUS_20240229 = 'claude-3-opus-20240229'

    CLAUDE_3_5_SONNET_20241022 = 'claude-3-5-sonnet-20241022'
    CLAUDE_3_5_SONNET_20240620 = 'claude-3-5-sonnet-20240620'
    CLAUDE_3_SONNET_20240229 = 'claude-3-sonnet-20240229'

    CLAUDE_3_5_HAIKU_20241022 = 'claude-3-5-haiku-20241022'
    CLAUDE_3_HAIKU_20240307 = 'claude-3-haiku-20240307'

    CLAUDE_OPUS_LATEST = CLAUDE_3_OPUS_20240229
    CLAUDE_SONNET_LATEST = CLAUDE_3_5_SONNET_20241022
    CLAUDE_HAIKU_LATEST = CLAUDE_3_5_HAIKU_20241022

    CLAUDE_FASTEST = CLAUDE_HAIKU_LATEST
    CLAUDE_CHEAPEST = CLAUDE_3_HAIKU_20240307
    CLAUDE_BALANCED = CLAUDE_SONNET_LATEST
    CLAUDE_SMARTEST = CLAUDE_3_5_SONNET_20240620

    CLAUDE_DEFAULT = CLAUDE_BALANCED
  end

  class Client

    def initialize(api_key, endpoint: nil, timeout: 60)
      @api_key = api_key
      @endpoint = endpoint || anthropic_endpoint
      @timeout = timeout

      raise(ArgumentError, "api_key is required") if api_key.nil?
    end

    def version
      'v1'
    end

    def anthropic_endpoint
      "https://api.anthropic.com/#{version}"
    end

    def messages_endpoint
      "#{anthropic_endpoint}/messages"
    end

    def messages(messages, params = {})
      model = params[:model] || Model::CLAUDE_DEFAULT
      max_tokens = params[:max_tokens] || 4096
      system = params[:system] || "You are a helpful assistant."
      timeout = params[:timeout] || @timeout

      data = {
        model: model,
        messages: messages,
        system: system,
        max_tokens: max_tokens,
        metadata: params[:metadata],
        stop_sequences: params[:stop_sequences],
        stream: params[:stream],
        temperature: params[:temperature],
        top_p: params[:top_p],
        top_k: params[:top_k],
      }.compact

      post_api(messages_endpoint, data, timeout)
    end

    def headers
      {
        'Content-Type' => 'application/json',
        'anthropic-version' => "2023-06-01",
        'x-api-key' => "#{@api_key}",
      }
    end

    def user_message(user_message)
      [
        {
          "role": "user",
          "content": user_message,
        }
      ]
    end

    def parse_response(response)
      response['content'][0]['text']
    end

    # for backwards compatibility with version 0.3.1
    def self.const_missing(const_name)
      if const_name.to_s.match(/^MODEL_(CLAUDE_.+)$/)
        new_const_name = $1
        if Claude::Model.constants.include?(new_const_name.to_sym)
          warn "[DEPRECATION] `#{const_name}` is deprecated. Please use `Claude::Model::#{new_const_name}` instead."
          Claude::Model.const_get(new_const_name)
        else
          super
        end
      else
        super
      end
    end

    private

    def post_api(url, data, timeout)
      response = HTTParty.post(url, body: data.to_json, headers: headers, timeout: timeout)
      if response && response['type'] == 'error'
        raise StandardError.new("#{response['error']['type']}: #{response['error']['message']}")
      else
        JSON.parse(response.body)
      end
    end
  end
end
