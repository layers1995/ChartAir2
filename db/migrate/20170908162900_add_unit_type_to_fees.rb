class AddUnitTypeToFees < ActiveRecord::Migration[5.0]
  def change
  	add_column :fees, :unit_type, :string
  end
end
