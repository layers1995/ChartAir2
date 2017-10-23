class AddEmailColumnToFbo < ActiveRecord::Migration[5.0]
  def change
  	add_column :fbos, :email, :string
  end
end
