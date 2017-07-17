class AddForeignKeysToFbo < ActiveRecord::Migration[5.0]
  def change
  	add_reference :fbos, :airports, index: true, foreign_key: true
  	add_reference :fbos, :classifications, index: true, foreign_key: true
  end
end
