class ChangePlanTripsUserIdToForeignKey < ActiveRecord::Migration[5.0]
  def change
  	remove_column :plan_trips, :user_id, :integer

  	add_column :plan_trips, :airplane_user_id, :integer
  	add_index :plan_trips, :airplane_user_id
  	add_foreign_key :plan_trips, :airplane_users
  end
end
