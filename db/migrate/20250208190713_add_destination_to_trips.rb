class AddDestinationToTrips < ActiveRecord::Migration[8.0]
  def change
    add_column :trips, :destination, :string
  end
end
