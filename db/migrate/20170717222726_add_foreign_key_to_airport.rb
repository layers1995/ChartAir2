class AddForeignKeyToAirport < ActiveRecord::Migration[5.0]
  def change
  	add_reference :airports, :city, index: true, foreign_key: true
  end
end
