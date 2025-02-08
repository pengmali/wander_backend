class TripsController < ApplicationController
  # ✅ GET /trips - List all trips
  def index
    if params[:user_id]
      user = User.find_by(id: params[:user_id])
      trips = user ? user.trips : []
    else
      trips = Trip.all  # Optional: Show all trips if not filtered
    end
    render json: trips
  end

  # ✅ GET /trips/:id - Get details of a specific trip
  def show
    trip = Trip.find_by(id: params[:id])
    if trip
      render json: trip
    else
      render json: { error: "Trip not found" }, status: :not_found
    end
  end

  # ✅ POST /trips - Create a new trip
  def create
    trip = Trip.new(trip_params)
    if trip.save
      render json: trip, status: :created
    else
      render json: trip.errors, status: :unprocessable_entity
    end
  end

  # ✅ PATCH /trips/:id - Update an existing trip
  def update
    trip = Trip.find_by(id: params[:id])
    if trip&.update(trip_params)
      render json: trip
    else
      render json: trip ? trip.errors : { error: "Trip not found" }, status: :unprocessable_entity
    end
  end

  # ✅ PATCH /trips/:id/update_costs - Update trip costs
  def update_costs
    trip = Trip.find_by(id: params[:id])
    if trip&.update(cost_params)
      render json: { id: trip.id, total_cost: trip.total_cost }
    else
      render json: trip ? trip.errors : { error: "Trip not found" }, status: :unprocessable_entity
    end
  end

  # ✅ DELETE /trips/:id - Delete a trip
  def destroy
    trip = Trip.find_by(id: params[:id])
    if trip
      trip.destroy
      render json: { message: "Trip deleted successfully" }
    else
      render json: { error: "Trip not found" }, status: :not_found
    end
  end

  private

  # Strong parameters to prevent mass assignment vulnerabilities
  def trip_params
    params.require(:trip).permit(:name, :start_date, :end_date, :budget, :total_cost, :is_guest_trip, :user_id)
  end

  # Separate params for cost updates
  def cost_params
    params.require(:trip).permit(:total_cost)
  end
end
