class AddFacebookToClientes < ActiveRecord::Migration
  def change
    add_column :clientes, :provider, :string
    add_column :clientes, :uid, :string
  end
end
