# Creada a mano para evitar que Devise filtre parámetros personalizados que se necesitan en la creación
# de un usuario como son nombreusuario, etc.
# Este controlador es activado desde routes
class ClienteregistrationsController < Devise::RegistrationsController
  
  def new
    @esconder_botones_login_entrar = true
    logger.info "ejecuta registrationscontroller new cliente"
    super
  end
  
  def create
    @esconder_botones_login_entrar = true
    logger.info "ejecuta RegistrationsController create cliente"
    session[:omniauth_data] = params[:cliente]
    #params.each do |key,value|
    #  Rails.logger.warn "Parametro #{key}: #{value}"
    #end
    super
  end
  
  def update
    @esconder_botones_login_entrar = true
    super
  end
  
  # Aquí permitimos parámetros que Devise no maneja y que usamos como personalizados STRONG PARAMETERS
  def sign_up_params
    @esconder_botones_login_entrar = true
    logger.info "ejecutando sign_up_params de cliente"
    permitidos = [:email, :password, :password_confirmation, :nombre, :apellido]
    params.require(resource_name).permit(permitidos)
  end
  
  def after_sign_up_path_for(clientes)
    ApplicationController::crear_foto_default(current_cliente)
    return inicio_cliente_index_path
  end
  
  
end