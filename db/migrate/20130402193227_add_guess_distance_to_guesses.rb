class AddGuessDistanceToGuesses < ActiveRecord::Migration
  def change
    add_column :guesses, :proximity_to_answer_in_feet, :integer
  end
end
