class CreateUserVotes < ActiveRecord::Migration
  def self.up
    create_table :user_votes do |t|
    end
  end

  def self.down
    drop_table :user_votes
  end
end
