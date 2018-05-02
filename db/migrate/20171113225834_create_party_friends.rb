class CreatePartyFriends < ActiveRecord::Migration[5.1]
  def change
    create_table :party_friends do |t|
      t.string :party
      t.string :friend_party
      t.date :date_party_friend
      t.integer :count

      t.timestamps
    end
  end
end
