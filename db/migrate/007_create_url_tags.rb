class CreateUrlTags < ActiveRecord::Migration
  def self.up
    create_table :url_tags do |t|
    end
  end

  def self.down
    drop_table :url_tags
  end
end
