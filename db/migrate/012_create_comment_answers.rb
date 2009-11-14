class CreateCommentAnswers < ActiveRecord::Migration
  def self.up
    create_table :comment_answers do |t|
    end
  end

  def self.down
    drop_table :comment_answers
  end
end
