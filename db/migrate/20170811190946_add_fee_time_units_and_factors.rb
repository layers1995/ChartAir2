class AddFeeTimeUnitsAndFactors < ActiveRecord::Migration[5.0]
  def change
  	add_column( :fees, :time_unit, :string)
  	add_column( :fees, :unit_price, :integer)
   	add_column( :fees, :unit_magnitude, :integer)
  end
end
