class UsersController < ApplicationController
  # ✅ POST /users - Register a new user
  def create
    user = User.new(user_params)
    if user.save
      render json: { message: "User created successfully", user: user }, status: :created
    else
      render json: user.errors, status: :unprocessable_entity
    end
  end

  # ✅ GET /users/:id - Retrieve user details
  def show
    user = User.find_by(id: params[:id])
    if user
      render json: user
    else
      render json: { error: "User not found" }, status: :not_found
    end
  end

  # ✅ PATCH /users/:id/preferences - Update user preferences
  def update_preferences
    user = User.find_by(id: params[:id])
    if user&.update(preferences_params)
      render json: { message: "Preferences updated successfully", preferences: user.travel_style }
    else
      render json: user ? user.errors : { error: "User not found" }, status: :unprocessable_entity
    end
  end

  # ✅ GET /users/:id/itineraries - List saved itineraries
  def itineraries
    user = User.find_by(id: params[:id])
    if user
      render json: user.trips
    else
      render json: { error: "User not found" }, status: :not_found
    end
  end

  # ✅ POST /users/:id/itineraries - Save an itinerary
  def save_itinerary
    user = User.find_by(id: params[:id])
    trip = Trip.find_by(id: params[:trip_id])

    if user && trip
      user.trips << trip unless user.trips.include?(trip)
      render json: { message: "Itinerary saved successfully", trip: trip }
    else
      render json: { error: "User or Trip not found" }, status: :not_found
    end
  end

  # ✅ DELETE /users/:id/itineraries/:itinerary_id - Remove a saved itinerary
  def remove_itinerary
    user = User.find_by(id: params[:id])
    trip = user&.trips&.find_by(id: params[:itinerary_id])

    if trip
      user.trips.delete(trip)
      render json: { message: "Itinerary removed successfully" }
    else
      render json: { error: "Itinerary not found" }, status: :not_found
    end
  end

  private

  # ✅ Strong parameters for user creation
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :travel_style)
  end

  # ✅ Strong parameters for updating preferences
  def preferences_params
    params.require(:user).permit(:travel_style)
  end
end
