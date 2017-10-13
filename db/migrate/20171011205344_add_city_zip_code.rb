class AddCityZipCode < ActiveRecord::Migration[5.0]
  def change
  	add_column :cities, :zip, :integer
  end
end
