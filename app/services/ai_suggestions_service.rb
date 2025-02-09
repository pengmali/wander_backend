class AiSuggestionsService
  def initialize(destination, budget, start_date, trip_length, travel_styles)
    @destination = destination
    @budget = budget.to_i
    @start_date = start_date
    @trip_length = trip_length
    @travel_styles = travel_styles
    @open_ai_service = OpenAiService.new(@destination, @budget, @start_date, @trip_length, @travel_styles)
  end

  def get_itinerary
    data = @open_ai_service.fetch_itinerary
    return [] unless data

    organize_itinerary(data)
  end

  def get_more_attractions(count = 10)
    data = @open_ai_service.fetch_more_attractions(count)
    data['attractions'] || []
  end

  def get_more_restaurants(count = 10)
    data = @open_ai_service.fetch_more_restaurants(count)
    data['restaurants'] || []
  end

  def get_more_lodging(count = 5)
    data = @open_ai_service.fetch_more_lodging(count)
    data['lodging'] || []
  end

  private

  def organize_itinerary(data)
    itinerary = []
    attractions = data['attractions']
    restaurants = data['restaurants']
    lodging = data['lodging']

    (1..@trip_length).each do |day|
      itinerary << {
        day: day,
        attractions: attractions.shift(3),
        restaurants: restaurants.shift(2),
        lodging: lodging[(day - 1) / 3] # Lodging changes every 3 days
      }
    end

    itinerary
  end
end
