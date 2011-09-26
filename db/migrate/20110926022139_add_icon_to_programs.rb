class AddIconToPrograms < ActiveRecord::Migration
  def self.up
    add_column :programs, :icon, :binary
  end

  def self.down
    remove_column :programs, :icon
  end
end
