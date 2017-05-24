class AddSobreTiToClientes < ActiveRecord::Migration
  def change
    add_column :clientes, :sobre_ti, :string, :limit => 300
  end
end
