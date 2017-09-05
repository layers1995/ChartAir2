class AddAirplaneUserIdToTrips < ActiveRecord::Migration[5.0]
  def change
    add_column :trips, :airplane_user_id, :integer
  end
end
