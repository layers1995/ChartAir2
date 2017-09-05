class AddDepartTimeToPlanTrips < ActiveRecord::Migration[5.0]
  def change
    add_column :plan_trips, :depart_time, :datetime
  end
end
