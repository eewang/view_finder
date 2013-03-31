class AddSmallimageToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :small_image, :string
  end
end
