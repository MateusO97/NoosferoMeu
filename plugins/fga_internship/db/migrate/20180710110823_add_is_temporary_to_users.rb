class AddIsTemporaryToUsers < ActiveRecord::Migration[5.0]
  def self.up
    add_column :users, :is_temporary, :boolean, :default => false
    add_column :users, :expiration_date, :datetime, :default => nil
  end

  def self.down
    remove_column :users, :is_temporary
    remove_column :users, :expiration_date
  end
end
