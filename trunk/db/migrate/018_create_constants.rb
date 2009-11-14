class CreateConstants < ActiveRecord::Migration
  def self.up
    create_table :constants do |t|
    end
  end

  def self.down
    drop_table :constants
  end
end
