class RenameFieldInGlobalVersions < ActiveRecord::Migration
  def self.up
    rename_column :global_versions, :public_function_id, :global_id
    remove_column :globals, :code
    remove_column :programs, :start_code
    remove_column :programs, :loop_code
  end

  def self.down
  end
end
