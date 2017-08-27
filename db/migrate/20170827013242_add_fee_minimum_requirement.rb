class AddFeeMinimumRequirement < ActiveRecord::Migration[5.0]
  def change
  	add_column :fees, :unit_minimum, :integer
  end
end
