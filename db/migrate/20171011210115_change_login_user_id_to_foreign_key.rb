class ChangeLoginUserIdToForeignKey < ActiveRecord::Migration[5.0]
  def change
  	add_index :logins, :user_id
  	add_foreign_key :logins, :users
  end
end
