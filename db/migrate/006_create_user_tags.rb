class CreateUserTags < ActiveRecord::Migration
  def self.up
    create_table :user_tags do |t|
    end
  end

  def self.down
    drop_table :user_tags
  end
end
