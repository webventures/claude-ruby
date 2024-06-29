require 'httparty'
require 'json'

module Claude
  class Client
    MODEL_CLAUDE_3_OPUS_20240229 = 'claude-3-opus-20240229'

    MODEL_CLAUDE_3_SONNET_20240229 = 'claude-3-sonnet-20240229'
    MODEL_CLAUDE_3_5_SONNET_20240620 = 'claude-3-5-sonnet-20240620'

    MODEL_CLAUDE_3_HAIKU_20240307 = 'claude-3-haiku-20240307'

    MODEL_CLAUDE_OPUS_LATEST = MODEL_CLAUDE_3_OPUS_20240229
    MODEL_CLAUDE_SONNET_LATEST = MODEL_CLAUDE_3_5_SONNET_20240620
    MODEL_CLAUDE_HAIKU_LATEST = MODEL_CLAUDE_3_HAIKU_20240307

    MODEL_CLAUDE_FASTEST = MODEL_CLAUDE_HAIKU_LATEST
    MODEL_CLAUDE_CHEAPEST = MODEL_CLAUDE_HAIKU_LATEST
    MODEL_CLAUDE_BALANCED = MODEL_CLAUDE_SONNET_LATEST
    MODEL_CLAUDE_SMARTEST = MODEL_CLAUDE_3_5_SONNET_20240620

    MODEL_CLAUDE_DEFAULT = MODEL_CLAUDE_SONNET_LATEST

    def initialize(api_key)
      @api_key = api_key
      @endpoint = 'https://api.anthropic.com/v1'
    end

    def messages(messages, params = {})
      model = params[:model] || MODEL_CLAUDE_DEFAULT
      max_tokens = params[:max_tokens] || 4096
      system = params[:system] || "You are a helpful assistant."

      url = "#{@endpoint}/messages"

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

      post_api(url, data)
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

    private

    def post_api(url, data)
      response = HTTParty.post(url, body: data.to_json, headers: headers)
      if response && response['type'] == 'error'
        raise StandardError.new("#{response['error']['type']}: #{response['error']['message']}")
      else
        JSON.parse(response.body)
      end
    end

  end
end
