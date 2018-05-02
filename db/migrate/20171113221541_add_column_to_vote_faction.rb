class AddColumnToVoteFaction < ActiveRecord::Migration[5.1]
  def change
    add_column :vote_factions, :division_id, :integer
    remove_column :vote_factions, :vote_aye, :integer
    remove_column :vote_factions, :date, :date
    add_column :vote_factions, :aye, :boolean, default: false
  end
end
