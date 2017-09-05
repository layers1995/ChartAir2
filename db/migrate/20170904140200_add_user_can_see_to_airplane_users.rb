class AddUserCanSeeToAirplaneUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :airplane_users, :user_can_see, :boolean
  end
end
