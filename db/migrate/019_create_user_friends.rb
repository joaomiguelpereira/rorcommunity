class CreateUserFriends < ActiveRecord::Migration
  def self.up
    create_table :user_friends do |t|
    end
  end

  def self.down
    drop_table :user_friends
  end
end
