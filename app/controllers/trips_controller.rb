class TripsController < ApplicationController
  # Creates a new trip with provided parameters
  def create
    trip = Trip.new(trip_params)

    if trip.save
      render json: { message: 'Trip created successfully', trip: trip }, status: :created
    else
      render json: { error: trip.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # Lists all trips
  def index
    trips = Trip.all
    render json: trips
  end

  # Shows details of a specific trip
  def show
    trip = Trip.find(params[:id])
    render json: trip
  end

  # Deletes a specific trip
  def destroy
    trip = Trip.find(params[:id])
    trip.destroy
    render json: { message: 'Trip deleted successfully' }
  end

  private

  # Strong parameters for trip creation
  def trip_params
    params.require(:trip).permit(:destination, :start_date, :end_date, :budget, :trip_length, :is_guest_trip, :preferences, itinerary: [:day, attractions: [:name, :description, :cost, :category, :google_link], restaurants: [:name, :description, :cost, :category, :google_link], lodging: [:name, :description, :cost, :category, :google_link]])
  end
end