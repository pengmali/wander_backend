require 'openai'

class OpenAIService
  OPENAI_API_KEY = ENV['OPENAI_API_KEY']

  def initialize(destination, preferences)
    @destination = destination
    @preferences = preferences
    @client = OpenAI::Client.new(access_token: OPENAI_API_KEY)
  end

  def fetch_suggestions
    response = @client.completions(parameters: {
      model: "gpt-4",
      prompt: "Suggest attractions and restaurants for #{@destination} with preferences: #{@preferences}",
      max_tokens: 100
    })
    response.dig("choices", 0, "text")&.strip
  rescue StandardError => e
    Rails.logger.error("OpenAI Error: #{e.message}")
    nil
  end
end