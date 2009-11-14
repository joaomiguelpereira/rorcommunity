class CreateCommentVotes < ActiveRecord::Migration
  def self.up
    create_table :comment_votes do |t|
    end
  end

  def self.down
    drop_table :comment_votes
  end
end
