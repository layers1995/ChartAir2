class CreateAirports < ActiveRecord::Migration[5.0]
  def change
    create_table :airports do |t|
    	t.string :airport_code
    	t.string :name
    	t.string :latitude
    	t.string :longitude
    	t.string :state
    	t.string :ownerPhone
    	t.string :managerPhone
      t.timestamps
    end
  end
end
