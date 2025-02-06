class CreateCosts < ActiveRecord::Migration[8.0]
  def change
    create_table :costs do |t|
      t.references :trip, foreign_key: true, null: false
      t.integer :category, null: false, default: 4  # Default: Other
      t.decimal :amount, precision: 10, scale: 2, null: false

      t.timestamps
    end
  end
end
