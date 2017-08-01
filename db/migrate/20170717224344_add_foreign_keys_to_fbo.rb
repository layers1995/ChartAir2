class AddForeignKeysToFbo < ActiveRecord::Migration[5.0]
  def change
  	add_reference :fbos, :airport, index: true, foreign_key: true
  	add_reference :fbos, :classification, index: true, foreign_key: true
  end
end
