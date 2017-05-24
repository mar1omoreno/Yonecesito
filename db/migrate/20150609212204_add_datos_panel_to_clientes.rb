class AddDatosPanelToClientes < ActiveRecord::Migration
  def change
    add_column :clientes, :codigo_verificacion_email, :string, :limit => 50
    add_column :clientes, :email_verificado, :integer, :limit => 1
  end
end
