class CreateConfigurations < ActiveRecord::Migration
  def self.up
    create_table :configurations do |t|
    end
  end

  def self.down
    drop_table :configurations
  end
end
