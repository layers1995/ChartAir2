class AddFreeTimeToFees < ActiveRecord::Migration[5.0]
  def change
  	add_column :fees, :free_time_unit, :string
  	add_column :fees, :free_time_length, :integer
  end
end
