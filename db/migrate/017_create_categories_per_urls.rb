class CreateCategoriesPerUrls < ActiveRecord::Migration
  def self.up
    create_table :categories_per_urls do |t|
    end
  end

  def self.down
    drop_table :categories_per_urls
  end
end
