class AiSuggestionsService
  def initialize(destination, budget, start_date, trip_length, travel_styles)
    @destination = destination
    @budget = budget.to_i
    @start_date = start_date
    @trip_length = trip_length
    @travel_styles = travel_styles
  end

  def get_suggestions
    Rails.logger.info("Fetching suggestions for #{@destination}, Budget: #{@budget}, Trip Length: #{@trip_length}")

    suggestions = OpenAiService.new(@destination, @budget, @start_date, @trip_length, @travel_styles).fetch_suggestions_for_trip
    Rails.logger.info("Initial suggestions fetched: #{suggestions.size} days")
  
    begin
      loop do
        Rails.logger.info("Starting deduplication process")
        suggestions = deduplicate_places(suggestions)
        Rails.logger.info("After deduplication: #{suggestions.size} days")
  
        Rails.logger.info("Filling missing days if any")
        suggestions = fill_missing_days(suggestions)
        Rails.logger.info("After filling missing days: #{suggestions.size} days")
  
        Rails.logger.info("Re-running deduplication")
        suggestions = deduplicate_places(suggestions)
        Rails.logger.info("After re-deduplication: #{suggestions.size} days")
  
        missing_days = (1..@trip_length).to_a - suggestions.map { |day| day['day'].to_i }
        Rails.logger.info("Missing days after iteration: #{missing_days}")
        break if missing_days.empty?
      end
  
      Rails.logger.info("Ensuring Google links")
      suggestions = ensure_google_links(suggestions)
  
      Rails.logger.info("Sorting by day")
      suggestions = sort_by_day(suggestions)
  
      if exceeds_budget?(suggestions)
        Rails.logger.warn("Suggestions exceed budget of $#{@budget}")
        return adjust_to_budget(suggestions)
      end
  
    rescue StandardError => e
      Rails.logger.error("Error during processing: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))  # This will give the exact line number
      return { error: "Processing error occurred" }
    end
  
    suggestions
  end

  private

  def deduplicate_places(suggestions)
    suggestions.each do |day|
      next unless day.is_a?(Hash)
      all_places = extract_all_places(day)
      unique_places = all_places.uniq { |place| [place['name'], place['address']] }

      day['attractions'] = unique_places.select { |p| p['category'] == 'attraction' }
      day['restaurants'] = unique_places.select { |p| p['category'] == 'restaurant' }
      day['lodging'] = unique_places.find { |p| p['category'] == 'lodging' }
    end
    suggestions
  end

  def fill_missing_days(suggestions)
    missing_days = (1..@trip_length).to_a - suggestions.map { |day| day['day'].to_i rescue 0 }
    return suggestions if missing_days.empty?

    missing_days.each do |day_number|
      new_suggestion = OpenAiService.new(@destination, @budget, @start_date, 1, @travel_styles).fetch_suggestions_for_trip
      suggestions << new_suggestion.first if new_suggestion.is_a?(Array)
    end

    suggestions
  end

  def ensure_google_links(suggestions)
    suggestions.each do |day|
      extract_all_places(day).each do |place|
        next if place['google_place_link']
        place_name_encoded = URI.encode(place['name'].to_s)
        place['google_place_link'] = "https://www.google.com/maps/search/?api=1&query=#{place_name_encoded}"
      end
    end
    suggestions
  end

  def sort_by_day(suggestions)
    suggestions.sort_by do |day|
      if day['day'].is_a?(Integer)
        day['day']
      elsif day.keys.any? { |k| k.to_s.downcase.include?('day') }
        key = day.keys.find { |k| k.to_s.downcase.include?('day') }
        key.to_s.scan(/\d+/).first.to_i rescue 0
      else
        0
      end
    end
  end

  def exceeds_budget?(suggestions)
    total_cost = suggestions.sum { |day| extract_total_cost(day) rescue 0 }
    total_cost > @budget
  end

  def adjust_to_budget(suggestions)
    suggestions.each do |day|
      all_places = extract_all_places(day)
      next unless all_places.any?

      all_places.sort_by! { |place| -extract_cost(place) }
      total_cost = all_places.sum { |place| extract_cost(place) }

      while total_cost > @budget && all_places.size > 1
        all_places.pop
        total_cost = all_places.sum { |place| extract_cost(place) }
      end
    end
    suggestions
  end

  def extract_all_places(day)
    attractions = day['attractions'] || (day.values.first.is_a?(Hash) && day.values.first['Attractions']) || []
    restaurants = day['restaurants'] || (day.values.first.is_a?(Hash) && day.values.first['Restaurants']) || []
    lodging = day['lodging'] || (day.values.first.is_a?(Hash) && day.values.first['Lodging']) || {}
    [*attractions, *restaurants, lodging].compact
  end

  def extract_cost(place)
    return 0 if place.nil?
    cost = place['cost'] || place['price'] || "0"
    return 0 if cost.to_s.downcase.include?("free")
    cost.to_s.scan(/\d+/).join.to_i
  end

  def extract_total_cost(day)
    extract_all_places(day).sum { |place| extract_cost(place) rescue 0 }
  end
end
