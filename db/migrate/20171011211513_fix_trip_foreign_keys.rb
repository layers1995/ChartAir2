class FixTripForeignKeys < ActiveRecord::Migration[5.0]
  def change
  	remove_column :trips, :airport_id, :integer
  	remove_column :trips, :user_id, :integer

  	add_index :trips, :fbo_id
  	add_foreign_key :trips, :fbos

  	add_index :trips, :airplane_user_id
  	add_foreign_key :trips, :airplane_users
  end
end
