require 'minitest/autorun'
require 'claude/client'

class TestClaudeMessagesIntegration < Minitest::Test
  def setup
    @api_key = ENV['ANTHROPIC_API_KEY']
    @client = Claude::Client.new(@api_key)
  end

  def test_messages_returns_valid_response
    response = @client.messages([{ role: "user", content: "What's the Greek name for Sun?" }])
    assert response["content"].length > 0
    assert response["content"][0]["text"] != nil
  end
  
  def test_messages_with_extra_config
    extra_config = {
      model: "claude-2.1",
      max_tokens: 100,
      temperature: 0.5,
    }

    response = @client.messages([{ role: "user", content: "What's the Greek name for Sun?"}], extra_config)
    assert response["content"].length > 0
    assert response["content"][0]["text"] != nil
  end

  def test_messages_returns_valid_response_when_prompt_is_empty
    assert_raises(StandardError) do
      @client.messages([{ role: "user", content: ""}])
    end
  end

  def test_messages_returns_error_with_invalid_model
    model = "INVALID"
    assert_raises(StandardError) do
      @client.messages([{ role: "user", content: "What's the Greek name for Sun?"}], {model: model})
    end
  end

  def test_messages_returns_error_with_invalid_max_tokens
    max_tokens = -10
    assert_raises(StandardError) do
      @client.messages([{ role: "user", content: "What's the Greek name for Sun?"}], {max_tokens: max_tokens})
    end
  end

  def test_user_message
    user_message = "What's the Greek name for Sun?"
    assert @client.user_message(user_message) == [{ role: "user", content: "What's the Greek name for Sun?" }]
  end

  def test_parse_response
    response = @client.messages([{ role: "user", content: "What's the Greek name for Sun?" }])
    assert @client.parse_response(response).length > 0
    assert @client.parse_response(response) == response["content"][0]["text"]
  end

end
