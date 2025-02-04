class CreateTrips < ActiveRecord::Migration[8.0]
  def change
    create_table :trips do |t|
      t.references :user, foreign_key: true, null: true  # Trip is optional for users
      t.string :name, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.integer :trip_length, null: false, default: 7  # Default to 7 days
      t.decimal :budget, precision: 10, scale: 2  # Optional, defaults to 200/day
      t.decimal :total_cost, precision: 10, scale: 2, default: 0.0  # Sum of place costs

      t.timestamps
    end
  end
end
