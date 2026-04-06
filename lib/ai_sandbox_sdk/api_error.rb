# frozen_string_literal: true

module AiSandboxSdk
  class ApiError < StandardError
    attr_reader :status, :body, :trace_id

    def initialize(status, body, trace_id = nil)
      msg = trace_id.nil? || trace_id.empty? ? "HTTP #{status}: #{body}" : "HTTP #{status}: #{body} (trace_id=#{trace_id})"
      super(msg)
      @status = status
      @body = body
      @trace_id = trace_id
    end
  end
end
