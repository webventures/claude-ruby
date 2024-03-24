require 'httparty'
require 'json'

module Claude
  class Client

    def initialize(api_key)
      @api_key = api_key
      @endpoint = 'https://api.anthropic.com/v1'
    end

    def messages(messages, params = {})
      model = params[:model] || 'claude-3-opus-20240229'
      max_tokens = params[:max_tokens] || 1024

      url = "#{@endpoint}/messages"

      data = {
        model: model,
        messages: messages,
        system: params[:system],
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
