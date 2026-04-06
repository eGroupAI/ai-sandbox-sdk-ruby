# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/ai_sandbox_sdk/http_retry_policy"

class HttpRetryPolicyTest < Minitest::Test
  def test_transient_retry_idempotent_only
    assert AiSandboxSdk::HttpRetryPolicy.should_retry_transient_http?("GET", 503)
    refute AiSandboxSdk::HttpRetryPolicy.should_retry_transient_http?("POST", 503)
    refute AiSandboxSdk::HttpRetryPolicy.should_retry_transient_http?("GET", 404)
  end

  def test_exponential_backoff_with_cap
    assert_equal 0.2, AiSandboxSdk::HttpRetryPolicy.retry_delay_seconds(1)
    assert_equal 0.4, AiSandboxSdk::HttpRetryPolicy.retry_delay_seconds(2)
    assert_equal 0.8, AiSandboxSdk::HttpRetryPolicy.retry_delay_seconds(3)
    assert_equal 1.6, AiSandboxSdk::HttpRetryPolicy.retry_delay_seconds(4)
    assert_equal 2.0, AiSandboxSdk::HttpRetryPolicy.retry_delay_seconds(5)
    assert_equal 2.0, AiSandboxSdk::HttpRetryPolicy.retry_delay_seconds(9)
  end
end
