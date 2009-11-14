class CreateUserContacts < ActiveRecord::Migration
  def self.up
    create_table :user_contacts do |t|
    end
  end

  def self.down
    drop_table :user_contacts
  end
end
