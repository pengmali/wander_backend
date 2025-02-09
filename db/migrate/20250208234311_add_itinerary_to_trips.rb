class AddItineraryToTrips < ActiveRecord::Migration[8.0]
  def change
    add_column :trips, :itinerary, :jsonb
  end
end
