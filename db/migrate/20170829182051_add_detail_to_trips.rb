class AddDetailToTrips < ActiveRecord::Migration[5.0]
  def change
    add_column :trips, :detail, :string
  end
end
