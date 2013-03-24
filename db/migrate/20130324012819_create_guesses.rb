class CreateGuesses < ActiveRecord::Migration
  def change
    create_table :guesses do |t|
      t.references :user
      t.references :photo
      t.float :latitude
      t.float :longitude
      t.string :street_address
      t.string :city
      t.string :state
      t.string :country

      t.timestamps
    end
  end
end
