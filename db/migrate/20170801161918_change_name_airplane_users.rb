class ChangeNameAirplaneUsers < ActiveRecord::Migration[5.0]
  def change
    rename_table :airplanes_users, :airplane_users
  end
end
