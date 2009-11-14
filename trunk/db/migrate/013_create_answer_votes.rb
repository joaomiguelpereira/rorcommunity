class CreateAnswerVotes < ActiveRecord::Migration
  def self.up
    create_table :answer_votes do |t|
    end
  end

  def self.down
    drop_table :answer_votes
  end
end
