class AddValidoToCreditos < ActiveRecord::Migration
  def change
    add_column :creditos, :valido, :integer, :default => 0, :limit => 1
    add_column :creditos, :codtran_pademobile, :string, :limit => 40
  end
end
