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
    initialize_service_params

    cache_key = "search_#{@destination}_#{@budget}_#{@start_date}_#{@trip_length}_#{@travel_styles.sort.join("_")}".parameterize

    cached_result = Rails.cache.read(cache_key)
    if cached_result
      Rails.logger.info("Cache hit for key: #{cache_key}")
      return render json: cached_result, status: :ok
    end

    itinerary = @itinerary_service.get_itinerary
    response = { itinerary: itinerary }

    Rails.cache.write(cache_key, response, expires_in: 12.hours)
    Rails.logger.info("New search cached for key: #{cache_key}")

    render json: response, status: :ok
  rescue StandardError => e
    Rails.logger.error("Search Error: #{e.message}")
    render json: { error: "Search failed" }, status: :unprocessable_entity
  end

  def more_attractions
    initialize_service_params
    attractions = @itinerary_service.get_more_attractions(params[:count] || 10)

    if attractions.empty?
      Rails.logger.error("No attractions returned from OpenAI.")
      return render json: { error: "Failed to fetch more attractions" }, status: :unprocessable_entity
    end

    render json: { attractions: attractions }, status: :ok
  rescue StandardError => e
    Rails.logger.error("More Attractions Error: #{e.message}")
    render json: { error: "Failed to fetch more attractions" }, status: :unprocessable_entity
  end

  def more_restaurants
    initialize_service_params
    restaurants = @itinerary_service.get_more_restaurants(params[:count] || 10)

    if restaurants.empty?
      Rails.logger.error("No restaurants returned from OpenAI.")
      return render json: { error: "Failed to fetch more restaurants" }, status: :unprocessable_entity
    end

    render json: { restaurants: restaurants }, status: :ok
  rescue StandardError => e
    Rails.logger.error("More Restaurants Error: #{e.message}")
    render json: { error: "Failed to fetch more restaurants" }, status: :unprocessable_entity
  end

  def more_lodging
    initialize_service_params
    lodging = @itinerary_service.get_more_lodging(params[:count] || 5)

    if lodging.empty?
      Rails.logger.error("No lodging returned from OpenAI.")
      return render json: { error: "Failed to fetch more lodging" }, status: :unprocessable_entity
    end

    render json: { lodging: lodging }, status: :ok
  rescue StandardError => e
    Rails.logger.error("More Lodging Error: #{e.message}")
    render json: { error: "Failed to fetch more lodging" }, status: :unprocessable_entity
  end

  private

  def initialize_service_params
    @destination = params[:destination]
    @budget = params[:budget]
    @start_date = params[:start_date]
    @trip_length = params[:trip_length].to_i
    preferences = params[:preferences]

    @travel_styles = preferences.to_s.downcase.split(",").map do |pref|
      TRAVEL_STYLE_MAP[pref.strip] || :not_specified
    end.uniq

    @itinerary_service = AiSuggestionsService.new(@destination, @budget, @start_date, @trip_length, @travel_styles)
  end
end
