class AddTimeStartEndToFees < ActiveRecord::Migration[5.0]
  def change
  	add_column :fees, :start_time, :time
  	add_column :fees, :end_time, :time
  end
end
