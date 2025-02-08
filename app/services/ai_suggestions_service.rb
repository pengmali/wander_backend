class AiSuggestionsService
  def initialize(destination, budget, start_date, trip_length, travel_styles)
    @destination = destination
    @budget = budget.to_i
    @start_date = start_date
    @trip_length = trip_length
    @travel_styles = travel_styles
  end

  def get_itinerary
    data = OpenAiService.new(@destination, @budget, @start_date, @trip_length, @travel_styles).fetch_itinerary
    return [] unless data

    organize_itinerary(data)
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

  # def extract_cost(item)
  #   return 0 if item.nil?
  #   cost = item['cost'] || item['price'] || "0"
  #   cost.to_s.scan(/\d+/).join.to_i
  # end
end
