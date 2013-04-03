class AddAuthToUsers < ActiveRecord::Migration
  def change
    add_column :users, :instagram_uid, :string
    add_column :users, :instagram_nickname, :string
    add_column :users, :instagram_token, :string
    add_column :users, :instagram_avatar, :string
  end
end
