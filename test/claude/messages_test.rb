require 'minitest/autorun'
require 'claude/client'

class TestClaudeMessagesIntegration < Minitest::Test
  def setup
    @api_key = ENV['CLAUDE_API_KEY']
    @client = Claude::Client.new(@api_key)
  end

  def test_messages_returns_valid_response
    response = @client.messages("What's the Greek name for Sun?")
    assert response["content"].length > 0
    assert response["content"][0]["text"] != nil
  end
  
  def test_messages_with_extra_config
    extra_config = {
      model: "claude-2.1",
      max_tokens: 100,
      temperature: 0.5,
    }

    response = @client.messages("What's the Greek name for Sun?", extra_config)
    assert_equal 2, response["content"].length
    assert response["content"][0]["text"] != nil
    assert response["content"][1]["text"] != nil
  end

  def test_messages_returns_valid_response_when_prompt_is_empty
    response = @client.messages("")
    assert response["content"].length > 0
    assert response["content"][0]["text"] != nil
  end

  def test_messages_returns_error_with_invalid_model
    prompt = "What's the Greek name for Sun?"
    model = "INVALID"
    assert_raises(RestClient::ExceptionWithResponse) do
      @client.messages(prompt, {model: model})
    end
  end

  def test_messages_returns_error_with_invalid_max_tokens
    prompt = "What's the Greek name for Sun?"
    max_tokens = -10
    assert_raises(RestClient::ExceptionWithResponse) do
      @client.messages(prompt, {max_tokens: max_tokens})
    end
  end
end
