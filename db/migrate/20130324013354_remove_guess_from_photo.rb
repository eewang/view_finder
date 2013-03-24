class RemoveGuessFromPhoto < ActiveRecord::Migration
  def up
    remove_column :photos, :guess_id
  end

  def down
    add_column :photos, :guess_id, :references
  end
end
