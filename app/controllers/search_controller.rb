require 'openai'

class SearchController < ApplicationController
  TRAVEL_STYLE_MAP = {
    "solo" => :solo,
    "hiking" => :hikers,
    "family" => :family_trip,
    "business" => :business_trip,
    "budget" => :budget_traveler,
    "luxury" => :luxury,
    "backpacking" => :backpacking,
    "romantic" => :romantic,
    "adventure" => :adventure,
    "cultural" => :cultural,
    "food" => :foodie,
    "relaxation" => :relaxation,
    "road" => :road_trip
  }

  def search
    destination = params[:destination]
    budget = params[:budget]
    start_date = params[:start_date]
    trip_length = params[:trip_length].to_i
    preferences = params[:preferences]

    travel_styles = preferences.to_s.downcase.split(",").map do |pref|
      TRAVEL_STYLE_MAP[pref.strip] || :not_specified
    end.uniq

    cache_key = "search_#{destination}_#{budget}_#{start_date}_#{trip_length}_#{travel_styles.sort.join("_")}".parameterize

    # ✅ Read from cache
    cached_result = Rails.cache.read(cache_key)
    if cached_result
      Rails.logger.info("Cache hit for key: #{cache_key}")
      return render json: cached_result, status: :ok
    end

    # 🚀 Fetch AI suggestions if not cached
    ai_response = AiSuggestionsService.new(destination, budget, start_date, trip_length, travel_styles).get_suggestions

    # ✅ Write to cache (cache expires in 12 hours, adjust as needed)
    Rails.cache.write(cache_key, ai_response, expires_in: 12.hours)

    Rails.logger.info("RAW AI RESPONSE: #{ai_response}") # Logs the raw response

    render json: { raw_ai_response: ai_response }, status: :ok
  rescue StandardError => e
    Rails.logger.error("Search Error: #{e.message}")
    render json: { error: "Search failed" }, status: :unprocessable_entity
  end
end
