class RemoveTailnumberFromPlanTrips < ActiveRecord::Migration[5.0]
  def change
  	remove_column :plan_trips, :tailnumber, :string
  end
end
