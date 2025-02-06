class AddIsGuestTripToTrips < ActiveRecord::Migration[8.0]
  def change
    add_column :trips, :is_guest_trip, :boolean, default: false, null: false
  end
end
