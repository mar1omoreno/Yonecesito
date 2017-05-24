class ProfesionistasessionsController < Devise::SessionsController
    after_filter :borrar_flash_sign_in_out, :only => [:create, :destroy]
    after_filter :crear_foto_default, :only => [:create]
    
    def new
        @esconder_botones_login_entrar = true
        @esconder_facebook = true
        logger.info "ejecuta sessioncontroller new profesionista"
        super
    end
    
    def after_sign_in_path_for(profesionistas)
        #Si no tiene trabajos ó teléfono fijo declarado, lo pedimos
        if ProfesionistasXTrabajos.where(id_profesionista: current_profesionista.id).count <= 0 || current_profesionista.tel_celular.blank?
            return filtros_profesionistas_filtroA_path
        else
            return inicio_profesionista_index_path
        end
    end
    
    def borrar_flash_sign_in_out
        flash.delete(:notice) #Para quitar mensajes de sign_in y out
    end

    def crear_foto_default
        ApplicationController::crear_foto_default(current_profesionista)
    end

end
