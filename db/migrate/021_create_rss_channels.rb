class CreateRssChannels < ActiveRecord::Migration
  def self.up
    create_table :rss_channels do |t|
    end
  end

  def self.down
    drop_table :rss_channels
  end
end
