class CreateUserPostVs < ActiveRecord::Migration
  def self.up
    create_table :user_post_vs do |t|
    end
  end

  def self.down
    drop_table :user_post_vs
  end
end
