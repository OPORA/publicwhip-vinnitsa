class CreateMpInfos < ActiveRecord::Migration[5.1]
  def change
    create_table :mp_infos do |t|
      t.integer :deputy_id
      t.integer :rebellions
      t.integer :not_voted
      t.integer :absent
      t.integer :against
      t.integer :aye_voted
      t.integer :abstain
      t.integer :votes_possible
      t.integer :votes_attended

      t.timestamps null: false
    end

  end
end
