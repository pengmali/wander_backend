class OpenAiService
  OPENAI_API_KEY = ENV['OPENAI_API_KEY']

  def initialize(destination, budget, start_date, trip_length, preferences)
    @destination = destination
    @budget = budget
    @start_date = start_date
    @trip_length = trip_length
    @preferences = preferences
    @client = OpenAI::Client.new(access_token: OPENAI_API_KEY)
  end

  def fetch_suggestions_for_trip
    full_itinerary = []
    days_per_request = 2  # Adjust as needed
    budget_per_request = @budget / (@trip_length.to_f / days_per_request).ceil

    threads = (1..@trip_length).step(days_per_request).map do |start_day|
      Thread.new do
        response = fetch_suggestions(start_day, days_per_request, budget_per_request)
        parsed_response = parse_response(response)
        full_itinerary.concat(parsed_response) if parsed_response
      end
    end

    threads.each(&:join)  # Wait for all threads to finish
    full_itinerary
  rescue StandardError => e
    Rails.logger.error("OpenAI Error: #{e.message}")
    nil
  end

  private

  def fetch_suggestions(start_day, days_per_request, budget_per_request, max_tokens: 1500)
    prompt = <<~PROMPT
      Provide recommendations for #{@destination}, focusing on #{@preferences} preferences,
      with a strict budget of $#{budget_per_request} for #{days_per_request} days starting from day #{start_day}.
      Respond ONLY with a valid JSON array of 3 attractions, 2 restaurants, and 1 lodging per day.
      Ensure the total cost for each period does NOT exceed $#{budget_per_request}.
    PROMPT

    response = @client.chat(
      parameters: {
        model: "gpt-4",
        messages: [
          { role: "system", content: "You are a helpful travel assistant." },
          { role: "user", content: prompt }
        ],
        max_tokens: max_tokens,
        temperature: 0.7
      }
    )

    response.dig("choices", 0, "message", "content")&.strip
  end

  def parse_response(response)
    JSON.parse(response)
  rescue JSON::ParserError
    Rails.logger.error("Invalid JSON response from OpenAI")
    nil
  end
end
