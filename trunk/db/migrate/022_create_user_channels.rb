class CreateUserChannels < ActiveRecord::Migration
  def self.up
    create_table :user_channels do |t|
    end
  end

  def self.down
    drop_table :user_channels
  end
end
