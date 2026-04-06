# frozen_string_literal: true

module AiSandboxSdk
  class ApiError < StandardError
    attr_reader :status, :body

    def initialize(status, body)
      super("HTTP #{status}: #{body}")
      @status = status
      @body = body
    end
  end
end
