class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email, unique: true
      t.string :password_digest
      t.integer :travel_style, default: 0  # Ensure default is set

      t.timestamps
    end
  end
end
