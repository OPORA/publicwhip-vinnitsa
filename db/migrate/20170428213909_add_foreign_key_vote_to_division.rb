class AddForeignKeyVoteToDivision < ActiveRecord::Migration[5.1]
  def change
    add_foreign_key :votes, :divisions, column: :division_id
    add_index :mps, :id, :unique => true
    add_foreign_key :votes, :mps, column: :deputy_id, primary_key: :id
  end
end
