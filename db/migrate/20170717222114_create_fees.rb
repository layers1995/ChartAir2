class CreateFees < ActiveRecord::Migration[5.0]
  def change
    create_table :fees do |t|
    	t.integer :price
      t.timestamps
    end
  end
end
