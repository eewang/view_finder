class AddGmapsToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :gmaps, :boolean
  end
end
