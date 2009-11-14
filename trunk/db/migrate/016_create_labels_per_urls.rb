class CreateLabelsPerUrls < ActiveRecord::Migration
  def self.up
    create_table :labels_per_urls do |t|
    end
  end

  def self.down
    drop_table :labels_per_urls
  end
end
