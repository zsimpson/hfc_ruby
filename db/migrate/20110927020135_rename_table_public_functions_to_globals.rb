class RenameTablePublicFunctionsToGlobals < ActiveRecord::Migration
  def self.up
    rename_table :public_functions, :globals
    rename_table :function_versions, :global_versions
  end

  def self.down
    rename_table :globals, :public_functions
    rename_table :glboal_versions, :function_versions
  end
end
