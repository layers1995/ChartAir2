class ChangeTripIdInReportsToForeignKey < ActiveRecord::Migration[5.0]
  def change
  	add_index :reports, :trip_id

  	add_foreign_key :reports, :trips
  end
end
