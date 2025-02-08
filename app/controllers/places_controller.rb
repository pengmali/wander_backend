class PlacesController < ApplicationController
  # ✅ GET /trips/:trip_id/places - List all places for a trip
  def index
    trip = Trip.find_by(id: params[:trip_id])
    if trip
      render json: trip.places
    else
      render json: { error: "Trip not found" }, status: :not_found
    end
  end

  # ✅ POST /trips/:trip_id/places - Add a new place to a trip
  def create
    trip = Trip.find_by(id: params[:trip_id])
    if trip
      place = trip.places.new(place_params)
      if place.save
        render json: place, status: :created
      else
        render json: place.errors, status: :unprocessable_entity
      end
    else
      render json: { error: "Trip not found" }, status: :not_found
    end
  end

  # ✅ PATCH /trips/:trip_id/places/:id/update_cost - Update place cost
  def update_cost
    trip = Trip.find_by(id: params[:trip_id])
    place = trip&.places&.find_by(id: params[:id])

    if place&.update(cost_params)
      render json: { id: place.id, cost: place.cost }
    else
      render json: place ? place.errors : { error: "Place not found" }, status: :unprocessable_entity
    end
  end

    # ✅ POST /trips/:trip_id/ai_suggestions - Get AI suggestions for places
    def ai_suggestions
      trip = Trip.find_by(id: params[:trip_id])
      return render json: { error: "Trip not found" }, status: :not_found unless trip
  
      preferences = params[:preferences]
      suggestions = AiSuggestionsService.new(trip.destination, preferences).get_suggestions
  
      if suggestions
        render json: suggestions, status: :ok
      else
        render json: { error: "Failed to fetch AI suggestions" }, status: :unprocessable_entity
      end
    end

  private

  # ✅ Strong parameters for creating a place
  def place_params
    params.require(:place).permit(:name, :category, :latitude, :longitude, :formatted_address, :cost, :rating, :duration)
  end

  # ✅ Strong parameters for updating cost
  def cost_params
    params.require(:place).permit(:cost)
  end
end
