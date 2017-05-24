class AddAttachmentAvatarToClientes < ActiveRecord::Migration
  def self.up
    change_table :clientes do |t|
      t.attachment :avatar
    end
  end

  def self.down
    remove_attachment :clientes, :avatar
  end
end
