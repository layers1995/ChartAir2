class AddEstimateBooleanToFees < ActiveRecord::Migration[5.0]
  def change
  	add_column :fees, :is_estimate, :boolean
  end
end
