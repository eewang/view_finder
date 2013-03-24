class AddLocationToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :user_name, :string
    add_column :photos, :location, :string
    add_column :photos, :link, :string
    add_column :photos, :caption, :string
    remove_column :photos, :user_id
  end
end
