class CreateUserVs < ActiveRecord::Migration
  def self.up
    create_table :user_vs do |t|
    end
  end

  def self.down
    drop_table :user_vs
  end
end
