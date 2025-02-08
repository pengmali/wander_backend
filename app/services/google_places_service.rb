require 'net/http'
require 'uri'
require 'json'

class GooglePlacesService
  GOOGLE_PLACES_API_KEY = ENV['GOOGLE_PLACES_API_KEY']

  def fetch_places(query)
    uri = URI("https://maps.googleapis.com/maps/api/place/textsearch/json")
    uri.query = URI.encode_www_form({ query: query, key: GOOGLE_PLACES_API_KEY })

    response = Net::HTTP.get_response(uri)
    JSON.parse(response.body)["results"]
  rescue StandardError => e
    Rails.logger.error("Google Places Error: #{e.message}")
    nil
  end
end