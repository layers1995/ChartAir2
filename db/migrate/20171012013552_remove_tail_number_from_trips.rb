class RemoveTailNumberFromTrips < ActiveRecord::Migration[5.0]
  def change
  	remove_column :trips, :tailnumber, :string
  end
end
