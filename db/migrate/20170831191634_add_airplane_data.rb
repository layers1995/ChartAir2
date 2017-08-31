class AddAirplaneData < ActiveRecord::Migration[5.0]
  def change
  	add_column :airplanes, :country, :string
  	add_column :airplanes, :plane_class, :string

  	add_column :airplanes, :empty_weight, :integer
  	add_column :airplanes, :num_crew, :integer
  	add_column :airplanes, :num_passengers, :integer
  	add_column :airplanes, :range, :integer
  	add_column :airplanes, :wing_area, :integer
  end
end
