class AddLocaleToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :locale_lat, :float
    add_column :photos, :locale_lon, :float
  end
end
