# encoding: utf-8
class Cliente < ActiveRecord::Base
  #has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
  #validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         
  devise :omniauthable, omniauth_providers: [:facebook]
  
  validates_presence_of :nombre, :apellido, on: :create

  
  # En esta aplicación no queremos que email sea obligatorio (por Facebook). Devise por default lo pide, pero también
  # busca una función email_required? para permitir cambiar el comportamiento. Creamos la función y listo
  def email_required?
    false # Puede requerir también migrar la base de datos quitando NOT NULL a columna email para que funcione: http://stackoverflow.com/a/9166015
  end
  validate :email_para_clientes_locales
  def email_para_clientes_locales
    if provider.blank? && email.blank?
      errors.add(:email, "Requerido para usuarios locales")
    end
  end
  validates :email, uniqueness: true, if: Proc.new {|a| not a.provider.blank?} #Valida único SOLO cuando hubo correo
  #validates :email, presence: true, if: Proc.new {|a| a.provider.blank? }, message: "Es necesario un correo en usuarios locales"  
  
  # Llamada por omniauth en login facebook.
  # Busca un usuario existente que tenga el proveedor (facebook) y el uid (facebook)
  def self.find_or_create_by_omniauth(auth)
    logger.info "find_or_create_by_omniauth con provider: #{auth[:provider]} y uid: #{auth[:uid]}"
    cliente = Cliente.where(provider: auth[:provider], uid: auth[:uid]).first
    #Si no hubo usuario logeado que exista en tabla...
    unless cliente
      # Creamos nuevo cliente con credenciales de facebook recibidas
      logger.info "NO existe cliente así que creamos uno"
      cliente = Cliente.create(
        nombre: auth[:nombre],
        apellido: auth[:apellido],
        #username: auth[:username],
        email: auth[:email],
        uid: auth[:uid],
        provider: auth[:provider],
        password: Devise.friendly_token[0,20] #Devise provee contraseña aleatoria
      )
    end
    cliente # return
  end
  
  def nombre_completo
    return ( (nombre || "") + " " + (apellido || "") ).titleize
  end
  
end
