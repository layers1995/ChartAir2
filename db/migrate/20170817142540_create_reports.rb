class CreateReports < ActiveRecord::Migration[5.0]
  def change
    create_table :reports do |t|
      t.integer :trip_id
      t.integer :trip_rating
      t.string :trip_comments
      t.integer :fbo_rating
      t.string :fbo_comments

      t.timestamps
    end
  end
end
