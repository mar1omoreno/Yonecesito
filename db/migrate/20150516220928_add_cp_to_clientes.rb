class AddCpToClientes < ActiveRecord::Migration
  def change
    add_column :clientes, :cp, :string, :limit => 5
  end
end
