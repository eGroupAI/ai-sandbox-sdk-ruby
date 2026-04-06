# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/ai_sandbox_sdk/client"
require_relative "../lib/ai_sandbox_sdk/api_error"

class FakeResponse
  attr_reader :code, :body

  def initialize(code:, body:, headers: {})
    @code = code.to_s
    @body = body
    @headers = headers
  end

  def [](key)
    @headers[key]
  end
end

class FakeHttp
  attr_reader :calls

  def initialize(queue)
    @queue = queue
    @calls = 0
  end

  def request(_req)
    @calls += 1
    item = @queue.shift
    raise "mock queue depleted" if item.nil?
    raise item if item.is_a?(Exception)

    item
  end
end

class ClientContractTest < Minitest::Test
  def test_get_retries_on_transient_5xx_then_succeeds
    http = FakeHttp.new([
      FakeResponse.new(code: 503, body: "temporary failure"),
      FakeResponse.new(code: 200, body: "{\"ok\":true,\"payload\":{\"items\":[]}}")
    ])
    client = AiSandboxSdk::Client.new(base_url: "https://api.example.test", api_key: "test-key", timeout_seconds: 1, max_retries: 2)

    result = with_fake_http(http) { client.list_agents }

    assert_equal 2, http.calls
    assert_equal true, result["ok"]
  end

  def test_post_does_not_retry_on_http_5xx
    http = FakeHttp.new([
      FakeResponse.new(code: 503, body: "write failed", headers: { "x-trace-id" => "trace-post-1" })
    ])
    client = AiSandboxSdk::Client.new(base_url: "https://api.example.test", api_key: "test-key", timeout_seconds: 1, max_retries: 2)

    error = assert_raises(AiSandboxSdk::ApiError) do
      with_fake_http(http) { client.send_chat(123, { "channelId" => "c-1", "message" => "hello" }) }
    end

    assert_equal 1, http.calls
    assert_equal "trace-post-1", error.trace_id
  end

  def test_post_retries_on_network_fault_then_succeeds
    http = FakeHttp.new([
      Timeout::Error.new("network timeout"),
      FakeResponse.new(code: 200, body: "{\"ok\":true,\"payload\":{\"messageId\":\"m-1\"}}")
    ])
    client = AiSandboxSdk::Client.new(base_url: "https://api.example.test", api_key: "test-key", timeout_seconds: 1, max_retries: 2)

    result = with_fake_http(http) { client.send_chat(123, { "channelId" => "c-1", "message" => "hello" }) }

    assert_equal 2, http.calls
    assert_equal true, result["ok"]
  end

  private

  def with_fake_http(fake_http)
    Net::HTTP.stub(:start, ->(*_args, **_kwargs, &block) { block.call(fake_http) }) do
      yield
    end
  end
end
