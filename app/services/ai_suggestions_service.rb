class AiSuggestionsService
  def initialize(destination, preferences)
    @destination = destination
    @preferences = preferences
  end

  def get_suggestions
    ai_response = OpenAIService.new(@destination, @preferences).fetch_suggestions
    return unless ai_response

    GooglePlacesService.new.fetch_places(ai_response)
  end
end