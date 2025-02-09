class UsersController < ApplicationController
  def index
    users = User.all
    render json: users
  end

  def show
    user = User.find(params[:id])
    render json: user
  end

  def create
    user = User.new(user_params)
    if user.save
      render json: user, status: :created
    else
      render json: { error: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

 

  def save_itinerary
    user = User.find(params[:id])
    trip_params_with_default_name = trip_params
    trip_params_with_default_name[:name] ||= "Trip to #{trip_params[:destination]} on #{trip_params[:start_date]}"

    trip = Trip.new(trip_params_with_default_name)
    trip.user = user

    Rails.logger.debug("Trip Save Status: #{trip.save}")
    Rails.logger.debug("Trip Errors: #{trip.errors.full_messages}") unless trip.persisted?

    if trip.save
      render json: { message: 'Itinerary saved successfully', trip: trip }, status: :created
    else
      render json: { error: trip.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def itineraries
    user = User.find(params[:id])
    trips = user.trips
  
    render json: trips, status: :ok
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password)
  end

  def trip_params
    params.require(:trip).permit(:name, :destination, :start_date, :end_date, :budget, itinerary: [:day, attractions: [:name, :description, :cost, :category, :google_link], restaurants: [:name, :description, :cost, :category, :google_link], lodging: [:name, :description, :cost, :category, :google_link]])
  end
end
