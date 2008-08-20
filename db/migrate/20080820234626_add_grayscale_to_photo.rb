class AddGrayscaleToPhoto < ActiveRecord::Migration
  def self.up
    add_column :photos, :grayscale, :boolean
  end

  def self.down
    remove_column :photos, :grayscale
  end
end
