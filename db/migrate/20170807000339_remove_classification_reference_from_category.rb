class RemoveClassificationReferenceFromCategory < ActiveRecord::Migration[5.0]
  def change
  	remove_reference :categories, :classification
  end
end
