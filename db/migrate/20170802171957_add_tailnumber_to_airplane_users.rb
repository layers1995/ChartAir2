class AddTailnumberToAirplaneUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :airplane_users, :tailnumber, :string
  end
end
