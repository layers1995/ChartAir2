class AddIdToAirplaneUser < ActiveRecord::Migration[5.0]
  def change
    add_column :airplane_users, :id, :primary_key
  end
end
