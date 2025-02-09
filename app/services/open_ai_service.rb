require 'openai'

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

  def fetch_itinerary
    prompt = <<~PROMPT
      You are a travel assistant. Create a list of:
      - #{3 * @trip_length} attractions
      - #{2 * @trip_length} restaurants
      - #{(@trip_length / 3.0).ceil} lodging options (preferably one lodging for every 3 days)

      1. Destination: #{@destination}, Trip Start Date: #{@start_date}, Duration: #{@trip_length} days.
      2. Budget: $#{@budget} for the entire trip. Allocate the budget as follows:
      - 40% for accommodations (lodging)
      - 30% for food (restaurants)
      - 30% for activities (attractions)
      Ensure the costs for each category do not exceed the allocated budget. If needed, adjust the prices to fit within these limits.

      3. Preferences: #{@preferences.join(', ')}.


      Format:
      {
        "attractions": [{ "name": "Name", "description": "Description", "cost": 50, "rating": 4.5, "category": "attraction", "google_link": "https://www.google.com/maps/search/?api=1&query=Name" }],
        "restaurants": [{ "name": "Name", "description": "Description", "cost": 30, "rating": 4.0, "category": "restaurant", "google_link": "https://www.google.com/maps/search/?api=1&query=Name" }],
        "lodging": [{ "name": "Hotel Name", "description": "Description", "cost": 150, "rating": 4.7, "category": "lodging", "google_link": "https://www.google.com/maps/search/?api=1&query=Hotel+Name" }]
      }
    PROMPT

    response = @client.chat(
      parameters: {
        model: "gpt-4",
        messages: [
          { role: "system", content: "You are a helpful travel assistant." },
          { role: "user", content: prompt }
        ],
        max_tokens: 2000,
        temperature: 0.7
      }
    )

    parse_response(response.dig("choices", 0, "message", "content"))
  rescue StandardError => e
    Rails.logger.error("OpenAI Error: #{e.message}")
    nil 
  end

  private

  def parse_response(response)
    JSON.parse(response)
  rescue JSON::ParserError
    Rails.logger.error("Invalid JSON response from OpenAI")
    nil
  end
end
