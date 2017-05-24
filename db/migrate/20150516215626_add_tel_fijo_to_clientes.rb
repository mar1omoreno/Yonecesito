class AddTelFijoToClientes < ActiveRecord::Migration
  def change
    add_column :clientes, :tel_fijo, :string, :limit => 10
    add_column :clientes, :tel_celular, :string, :limit => 10
    add_column :clientes, :direccion, :string, :limit => 100
  end
end
