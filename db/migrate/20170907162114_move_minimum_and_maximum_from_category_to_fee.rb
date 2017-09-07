class MoveMinimumAndMaximumFromCategoryToFee < ActiveRecord::Migration[5.0]
  def change
  	remove_column :categories, :minimum
  	remove_column :categories, :maximum
  	add_column :fees, :unit_maximum, :integer
  end
end
