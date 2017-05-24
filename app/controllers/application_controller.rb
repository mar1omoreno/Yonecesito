class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  def validar_login_profesionista
    unless profesionista_signed_in?
      logger.info "validar_login_profesionista redirige a login"
      redirect_to new_profesionista_session_path
    else
      # Si NO estamos en Filtros Iniciales Y (no tiene trabajos ó teléfono fijo declarado) lo mandamos a filtros
      if !is_a?(FiltrosProfesionistasController) && (current_profesionista.tel_celular.blank? || ProfesionistasXTrabajos.where(id_profesionista: current_profesionista.id).count <= 0)
        redirect_to filtros_profesionistas_filtroA_path
      end
    end
  end
  
  def validar_login_cliente
    unless cliente_signed_in?
      logger.info "validar_login_cliente redirige a login"
      redirect_to new_cliente_session_path
    else
      #nada
    end
  end
  
  # Indica si hay PRESENTE parámetro en nivel 1 o 2
  def hay_parametro(llave1, llave2 = nil)
    if params[llave1].present?
      if llave2 == nil
        return true
      else
        return params[llave1][llave2].present?
      end
    else
      return false
    end
  end
  
  # Helper para mostrar 404 cuando sea apropiado
  def mostrar_404(msg= "Elemento no encontrado")
    raise ActionController::RoutingError.new(msg)
    #redirect_to inicio_cliente_index_path
    #redirect_to :status => 404
    #raise ActiveRecord::RecordNotFound.new(msg)
    #fail ActiveRecord::RecordNotFound, msg
  end


  # Función para crear foto default del tipo de usuario
  # En principio es llamada desde RegistrationsController y SessionsController al registrar por primera vez
  # y al crear sesión respectivamente para vigilar que exista siempre una foto del usuario
  def self.crear_foto_default(usuario)
    if usuario.is_a?(Cliente)
      carpeta = "fotos_clientes"
    else #elsif profesionista_signed_in
      carpeta = "fotos_profesionistas"
    end
    archivo = usuario.id.to_s
    archivo_destino = Rails.root.join('public', carpeta, archivo)
    if !File.exists?(archivo_destino )
      archivo_origen = Rails.root.join('public', "avatar.png")
      FileUtils.cp archivo_origen, archivo_destino
    end
  end
  
end
