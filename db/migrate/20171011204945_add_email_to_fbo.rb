class AddEmailToFbo < ActiveRecord::Migration[5.0]
  def change
  	Fbo.reset_column_information
  	add_column(:fbos, :email, :string) unless Fbo.column_names.include?('email')
  end
end
