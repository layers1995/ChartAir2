class AddForeignKeyToCategory < ActiveRecord::Migration[5.0]
  def change
  	add_reference :categories, :classification_types, index: true, foreign_key: true
  end
end
