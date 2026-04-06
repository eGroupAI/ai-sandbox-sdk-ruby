require_relative "../lib/ai_sandbox_sdk"

client = AiSandboxSdk::Client.new(
  base_url: ENV.fetch("AI_SANDBOX_BASE_URL", "https://www.egroupai.com"),
  api_key: ENV.fetch("AI_SANDBOX_API_KEY", "")
)

result = client.create_agent(
  "agentDisplayName" => "Ruby SDK Quickstart",
  "agentDescription" => "Created by Ruby SDK"
)
puts result
