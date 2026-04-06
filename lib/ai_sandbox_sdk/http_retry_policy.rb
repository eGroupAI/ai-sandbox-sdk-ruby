# frozen_string_literal: true

module AiSandboxSdk
  module HttpRetryPolicy
    module_function

    # Retry 429/5xx only for GET/HEAD to avoid duplicate write side effects.
    def should_retry_transient_http?(method, status)
      return false unless status == 429 || (500..599).cover?(status)

      m = method.to_s.strip.upcase
      m == "GET" || m == "HEAD"
    end

    def retry_delay_seconds(attempt)
      safe_attempt = [attempt.to_i, 1].max
      delay = 0.2 * (2**(safe_attempt - 1))
      [delay, 2.0].min
    end
  end
end
