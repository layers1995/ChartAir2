class ChangeFeeTimeToMinutes < ActiveRecord::Migration[5.0]
  def change
  	remove_column :fees, :start_time, :time
  	add_column :fees, :start_time, :integer
  	remove_column :fees, :end_time, :time
  	add_column :fees, :end_time, :integer
  end
end
