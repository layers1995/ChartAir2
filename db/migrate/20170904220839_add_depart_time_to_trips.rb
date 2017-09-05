class AddDepartTimeToTrips < ActiveRecord::Migration[5.0]
  def change
    add_column :trips, :depart_time, :datetime
  end
end
