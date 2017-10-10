class AddHashIdToFbos < ActiveRecord::Migration[5.0]
  
  def up
   add_column :fbos, :hash_id, :string, index: true
   Fbo.all.each{|m| m.set_hash_id; m.save}
  end
  
  def down
   remove_column :fbos, :hash_id, :string
  end
  
end
