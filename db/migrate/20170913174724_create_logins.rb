class CreateLogins < ActiveRecord::Migration[5.0]
  def change
    create_table :logins do |t|
      t.integer :user_id
      t.datetime :logout

      t.timestamps
    end
  end
end
