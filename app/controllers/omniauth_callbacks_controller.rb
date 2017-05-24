# encoding: utf-8

# Creado a mano para recibir logins correctos de omniauth (facebook, twitter)
# http://stackoverflow.com/a/24106240 puede ser útil para definir que los datos de facebook alimenten
# un formulario SIN registrar la cuenta en base local, de forma que podamos preguntar otras cosas
# al usuario antes ejecutar registro
# Este controlador es activado desde routes
class OmniauthCallbacksController < ApplicationController
  
  def facebook
    auth = request.env["omniauth.auth"] # Contiene información de login con omniauth
    # raise auth.to_yaml #Generamos excepción a propósito para analizar objeto de facebook regresado
    logger.info "INFORMACIÓN DE LOGIN EN FACEBOOK:"
    logger.info auth.to_yaml
   
    # if auth.info.email.blank?
    #  redirect_to "/clientes/auth/facebook?auth_type=rerequest&scope=email"
    # end
    
    #Estructura auth.info contiene valores de facebook
    datos = {
      nombre: auth.info.first_name,
      apellido: auth.info.last_name,
      #username: auth.uid,  # auth.info.nickname, nickname está obsoleto
      email: auth.info.email,
      provider: auth.provider,
      uid: auth.uid
    } 
    logger.info "buscamos cliente existente con datos: #{datos}"
    @cliente = Cliente.find_or_create_by_omniauth(datos)
    if @cliente.persisted?
      logger.info "Sesión iniciada en Facebook"
      flash[:notice] = "Sesión iniciada en Facebook"
      sign_in_and_redirect @cliente, event: :authentication
    else
      #Ejemplo si email de logeado en facebook ya existía en email de usuario local
      logger.info "No hay sesión en facebook:"
      session[:omniauth_errores] = @cliente.errors.full_messages.to_sentence unless @cliente.save
      session[:omniauth_data] = datos #Para que el formulario conserve los valores de UI del usuario (ApplicationHelper.get_email_oauth)
      redirect_to new_cliente_registration_url
    end
  end
end
