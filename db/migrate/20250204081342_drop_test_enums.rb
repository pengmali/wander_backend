class DropTestEnums < ActiveRecord::Migration[8.0]
  def up
    drop_table :test_enums, if_exists: true
  end

  def down
    create_table :test_enums do |t|
      t.integer :status
      t.timestamps
    end
  end
end
