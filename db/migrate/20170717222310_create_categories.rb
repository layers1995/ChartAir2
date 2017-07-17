class CreateCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :categories do |t|
    	t.string :category_description
    	t.integer :minimum
    	t.integer :maximum
      t.timestamps
    end
  end
end
