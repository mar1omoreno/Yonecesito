class ClientesessionsController < Devise::SessionsController
    after_filter :borrar_flash_sign_in_out, :only => [:create, :destroy]
    after_filter :crear_foto_default, :only => [:create]
    
    def new
        @esconder_botones_login_entrar = true
        logger.info "ejecuta sessioncontroller new cliente"
        super
    end
  
    def after_sign_in_path_for(clientes)
        inicio_cliente_index_path
        #sign_in_url = new_cliente_session_url
        #if request.referer == sign_in_url
            
         #   inicio_cliente_index_path
          #  super
        #else
         #   stored_location_for(clientes) || request.referer || inicio_cliente_index_path
        #end
    end
    
    def after_sign_out_path_for(clientes)
        root_path
    end
    
    def borrar_flash_sign_in_out
        flash.delete(:notice) #Para quitar mensajes de sign_in y out
    end

    def crear_foto_default
        ApplicationController::crear_foto_default(current_cliente)
    end
    
end
