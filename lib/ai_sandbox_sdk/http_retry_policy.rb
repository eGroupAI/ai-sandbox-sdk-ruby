# frozen_string_literal: true

module AiSandboxSdk
  module HttpRetryPolicy
    module_function

    # 僅對 GET/HEAD 在 429 或 5xx 時建議自動重試，避免寫入重複副作用。
    def should_retry_transient_http?(method, status)
      return false unless status == 429 || (500..599).cover?(status)

      m = method.to_s.strip.upcase
      m == "GET" || m == "HEAD"
    end
  end
end
