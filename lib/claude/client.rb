require 'rest-client'
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

      request_api(url, data)
    end

    def headers
      {
        'Content-Type' => 'application/json',
        'anthropic-version' => "2023-06-01",
        'x-api-key' => "#{@api_key}",
      }
    end

    private

    def request_api(url, data, method = :post)
      begin
        response = RestClient::Request.execute(method: method, url: url, payload: data.to_json, headers: headers)
        JSON.parse(response.body)
      rescue RestClient::ExceptionWithResponse => e
        error_msg = JSON.parse(e.response.body)['error']['message']
        raise RestClient::ExceptionWithResponse.new("#{e.message}: #{error_msg} (#{e.http_code})"), nil, e.backtrace
      end
    end

  end
end
