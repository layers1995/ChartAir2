class MoveClassificationFromFboToFee < ActiveRecord::Migration[5.0]
  def change
  	remove_reference :fbos, :classification
  	add_reference :fees, :classification, index: true, foreign_key: true
  end
end
