class CreateOpenidLogins < ActiveRecord::Migration
  def self.up
    create_table :openid_logins do |t|
    end
  end

  def self.down
    drop_table :openid_logins
  end
end
