class CreateUserPreferences < ActiveRecord::Migration
  def self.up
    create_table :user_preferences do |t|
    end
  end

  def self.down
    drop_table :user_preferences
  end
end
