class CreateUserImages < ActiveRecord::Migration
  def self.up
    create_table :user_images do |t|
    end
  end

  def self.down
    drop_table :user_images
  end
end
