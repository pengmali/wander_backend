class CreatePlaces < ActiveRecord::Migration[8.0]
  def change
    create_table :places do |t|
      t.references :trip, foreign_key: true, null: false
      t.string :name, null: false
      t.string :category, null: false  # Attraction, Restaurant, Hotel, etc.
      t.string :formatted_address, null: false  # Full address
      t.float :latitude, null: true
      t.float :longitude, null: true
      t.decimal :cost, precision: 10, scale: 2, default: 0.0  # Allow user input cost
      t.float :rating, null: true  # Rating out of 5
      t.integer :duration, null: true  # Time spent in minutes

      t.timestamps
    end
  end
end