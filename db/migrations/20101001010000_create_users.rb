class CreateUsers < ActiveRecord::Migration

  def change
    create_table :users, :force => true do |t|
      t.string   :email,                  :null => false, :limit => 128
      t.string   :encrypted_password,     :null => false, :default => ""
      #t.string   :reset_password_token,   :null => true
      #t.datetime :reset_password_sent_at, :null => true
      t.timestamps
    end

    add_index :users, :email, :name => :index_find_user_by_unique_email, :unique => true
    #add_index :users, :reset_password_token, :unique => true
  end

end
