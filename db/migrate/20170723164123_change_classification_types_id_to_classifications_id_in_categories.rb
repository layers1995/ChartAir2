class ChangeClassificationTypesIdToClassificationsIdInCategories < ActiveRecord::Migration[5.0]
  def change
  	rename_column :categories, :classification_types_id, :classifications_id
  end
end
