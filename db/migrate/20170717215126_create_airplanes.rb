class CreateAirplanes < ActiveRecord::Migration[5.0]
  def change
    create_table :airplanes do |t|
    	t.string :model
    	t.string :engine_class
    	t.integer :weight
    	t.integer :height
    	t.integer :wingspan
    	t.integer :length
      t.timestamps
    end
  end
end
