class AddForeignKeysToFee < ActiveRecord::Migration[5.0]
  def change
  	add_reference :fees, :fee_type, index: true, foreign_key: true
  	add_reference :fees, :fbo, index: true, foreign_key: true
  	add_reference :fees, :category, index: true, foreign_key: true
  end
end
