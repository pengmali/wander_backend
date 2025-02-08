require 'openai'
require 'dotenv/load'

client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])

response = client.chat(
  parameters: {
    model: "gpt-4",
    messages: [
      { role: "system", content: "You are a helpful travel assistant." },
      { role: "user", content: "Suggest attractions in Paris for art and culture lovers." }
    ],
    max_tokens: 100
  }
)

puts response.dig("choices", 0, "message", "content")&.strip
