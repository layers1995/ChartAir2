class AddArrivalTimeToPlanTrips < ActiveRecord::Migration[5.0]
  def change
    add_column :plan_trips, :arrival_time, :datetime
  end
end
