class AddForeignKeyToAirport < ActiveRecord::Migration[5.0]
  def change
  	remove_reference :airports, :cities, index: true, foreign_key: true # Yes, this is dumb. I fucked up
  	add_reference :airports, :cities, index: true, foreign_key: true
  end
end
