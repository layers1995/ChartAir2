class AddForeignKeysToFee < ActiveRecord::Migration[5.0]
  def change
  	add_reference :fees, :fee_types, index: true, foreign_key: true
  	add_reference :fees, :fbos, index: true, foreign_key: true
  	add_reference :fees, :categories, index: true, foreign_key: true
  end
end
