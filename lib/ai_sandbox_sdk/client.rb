# frozen_string_literal: true

require "json"
require "net/http"
require "socket"
require "timeout"
require "uri"
require_relative "http_retry_policy"

module AiSandboxSdk
  class Client
    def initialize(base_url:, api_key:, timeout_seconds: 30, max_retries: 2)
      @base_url = base_url.sub(%r{/+$}, "")
      @api_key = api_key
      @timeout_seconds = timeout_seconds
      @max_retries = max_retries
    end

    def create_agent(payload) = json("POST", "/agents", payload)
    def update_agent(agent_id, payload) = json("PUT", "/agents/#{agent_id}", payload)
    def list_agents(query: nil) = json("GET", "/agents#{query ? "?#{query}" : ""}")
    def get_agent_detail(agent_id) = json("GET", "/agents/#{agent_id}")
    def create_chat_channel(agent_id, payload) = json("POST", "/agents/#{agent_id}/channels", payload)
    def send_chat(agent_id, payload) = json("POST", "/agents/#{agent_id}/chat", payload)
    def get_chat_history(agent_id, channel_id, query: "limit=50&page=0") = json("GET", "/agents/#{agent_id}/channels/#{channel_id}/messages?#{query}")
    def get_knowledge_base_articles(agent_id, collection_id, query: "startIndex=0") = json("GET", "/agents/#{agent_id}/collections/#{collection_id}/articles?#{query}")
    def create_knowledge_base(agent_id, payload) = json("POST", "/agents/#{agent_id}/collections", payload)
    def update_knowledge_base_status(agent_collection_id, payload) = json("PATCH", "/agent-collections/#{agent_collection_id}/status", payload)
    def list_knowledge_bases(agent_id, query: "activeOnly=false") = json("GET", "/agents/#{agent_id}/collections?#{query}")

    def send_chat_stream(agent_id, payload)
      response = request("POST", "/agents/#{agent_id}/chat", payload, "text/event-stream")
      chunks = []
      done = false
      response.read_body do |part|
        part.each_line do |line|
          next unless line.start_with?("data: ")
          data = line.delete_prefix("data: ").strip
          if data == "[DONE]"
            done = true
            break
          end
          chunks << data
        end
        break if done
      end
      chunks
    end

    private

    def json(method, path, payload = nil)
      response = request(method, path, payload, "application/json")
      JSON.parse(response.body)
    end

    def request(method, path, payload, accept)
      attempt = 0
      loop do
        uri = URI("#{@base_url}/api/v1#{path}")
        klass = Net::HTTP.const_get(method.capitalize)
        req = klass.new(uri)
        req["Authorization"] = "Bearer #{@api_key}"
        req["Accept"] = accept
        if payload
          req["Content-Type"] = "application/json"
          req.body = JSON.generate(payload)
        end

        begin
          response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https", read_timeout: @timeout_seconds) do |http|
            http.request(req)
          end
        rescue Timeout::Error, Errno::ECONNRESET, Errno::ETIMEDOUT, SocketError, EOFError, IOError => e
          if attempt < @max_retries
            attempt += 1
            sleep(HttpRetryPolicy.retry_delay_seconds(attempt))
            next
          end
          raise RuntimeError, "Network error: #{e.message}"
        end

        if HttpRetryPolicy.should_retry_transient_http?(method, response.code.to_i) && attempt < @max_retries
          attempt += 1
          sleep(HttpRetryPolicy.retry_delay_seconds(attempt))
          next
        end

        if response.code.to_i >= 400
          trace = response["x-trace-id"]
          raise ApiError.new(response.code.to_i, response.body, trace)
        end
        return response
      end
    end
  end
end
