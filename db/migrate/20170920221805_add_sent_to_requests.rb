class AddSentToRequests < ActiveRecord::Migration[5.0]
  def change
    add_column :requests, :sent, :boolean
  end
end
