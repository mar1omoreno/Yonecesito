# Creada a mano para evitar que Devise filtre parámetros personalizados que se necesitan en la creación
# de un usuario como son nombre, apellido, etc.
# Este controlador es activado desde routes
class ProfesionistaregistrationsController < Devise::RegistrationsController
  
  def new
    @esconder_botones_login_entrar = true
    @esconder_facebook = true
    logger.info "ejecuta registrationscontroller new profesionista"
    super
  end
  
  def create
    @esconder_botones_login_entrar = true
    @esconder_facebook = true
    logger.info "ejecuta RegistrationsController create profesionista"
    session[:omniauth_data] = params[:profesionista]
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
    logger.info "ejecutando sign_up_params de profesionista"
    #TODO  cambiar en caso de ser necesario por datos mínimos para registro de profesionista
    #TODO En caso de no haber diferencia con Cliente, se puede borrar esta clase, cambiar nombre a ClietneRegistrationsController y en routes hacer que ambos modelos usen dicha clase
    permitidos = [:email, :password, :password_confirmation, :nombre, :apellido]
    params.require(resource_name).permit(permitidos)
  end
  
  def after_sign_up_path_for(profesionistas)
    ApplicationController::crear_foto_default(current_profesionista)
    return filtros_profesionistas_filtroA_path
  end


end