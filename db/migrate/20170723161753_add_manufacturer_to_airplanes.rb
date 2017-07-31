class AddManufacturerToAirplanes < ActiveRecord::Migration[5.0]
  def change
  	add_column :airplanes, :manufacturer, :string
  end
end
