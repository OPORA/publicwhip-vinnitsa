class CreateMpFriends < ActiveRecord::Migration[5.1]
  def change
    create_table :mp_friends do |t|
      t.integer :deputy_id
      t.integer :friend_deputy_id
      t.integer :count

      t.timestamps null: false
    end

  end
end
