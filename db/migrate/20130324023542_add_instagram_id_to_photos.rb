class AddInstagramIdToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :instagram_id, :string
  end
end
