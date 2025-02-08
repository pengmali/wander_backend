class SearchController < ApplicationController
  # ✅ POST /search - Handle trip and AI-based search queries
  def search
    destination = params[:destination]
    budget = params[:budget]
    start_date = params[:start_date]
    trip_length = params[:trip_length]
    preferences = params[:preferences]

    # Step 1: Search for existing trips (optional)
    trips = Trip.where("destination ILIKE ?", "%#{destination}%")
    trips = trips.where("budget <= ?", budget) if budget.present?
    trips = trips.where("start_date >= ?", start_date) if start_date.present?

    # Step 2: Get AI Suggestions
    ai_suggestions = AiSuggestionsService.new(destination, preferences).get_suggestions

    # Step 3: Return combined response
    render json: {
      trips: trips,
      ai_suggestions: ai_suggestions
    }, status: :ok
  rescue StandardError => e
    Rails.logger.error("Search Error: #{e.message}")
    render json: { error: "Search failed" }, status: :unprocessable_entity
  end
end