class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.string :image
      t.references :user
      t.references :guess
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
    add_index :photos, :user_id
    add_index :photos, :guess_id
  end
end
