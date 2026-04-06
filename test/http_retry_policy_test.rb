# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/ai_sandbox_sdk/http_retry_policy"

class HttpRetryPolicyTest < Minitest::Test
  def test_transient_retry_idempotent_only
    assert AiSandboxSdk::HttpRetryPolicy.should_retry_transient_http?("GET", 503)
    refute AiSandboxSdk::HttpRetryPolicy.should_retry_transient_http?("POST", 503)
    refute AiSandboxSdk::HttpRetryPolicy.should_retry_transient_http?("GET", 404)
  end
end
