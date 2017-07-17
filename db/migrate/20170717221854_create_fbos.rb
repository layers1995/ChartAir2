class CreateFbos < ActiveRecord::Migration[5.0]
  def change
    create_table :fbos do |t|
    	t.string :name
    	t.string :phone
    	t.string :alternate_phone
      t.timestamps
    end
  end
end
