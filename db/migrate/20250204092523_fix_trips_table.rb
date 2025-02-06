class FixTripsTable < ActiveRecord::Migration[8.0]
  def change
    # ✅ Fix `total_cost` default value (remove string)
    change_column_default :trips, :total_cost, 0.0

    # ✅ Ensure `budget` has a reasonable default
    change_column_default :trips, :budget, 1400.00  # Default: 7 days * $200/day

    # ✅ Fix `is_guest_trip` to ensure it's always set
    change_column_default :trips, :is_guest_trip, false
    change_column_null :trips, :is_guest_trip, false
  end
end
