class InicioController < ApplicationController
  
  def index
    @esconder_botones_login_entrar = false
    
    #categorias para servicios
    @hogar = TiposTrabajo.where(categoria: :hogar)
    @eventos = TiposTrabajo.where(categoria: :eventos)
    @bienestar = TiposTrabajo.where(categoria: :bienestar)
    @educacion = TiposTrabajo.where(categoria: :clases)
    render locals:{variable: "valor variable"}
  end
  
  def registrate
    @esconder_botones_login_entrar = true
  end
  
  def entra
    @esconder_botones_login_entrar = true
  end
  
  def yonecesito
  end
  
  # Llamado por usuario desde un link que se le envía por correo electrónico
  # El correo es enviado para profesionistas desde controlador inicio_profesionista.verificaciones
  # La vista se encuentra en views/inicio/validar_email_profesionista
  def validar_email_profesionista
    if params[:codigo_verificacion_email].present? && params[:id].present?
      # buscar profesionista. Si lo encuentra, actualiza validado y borra codigo_verificacion_email
      @profesionista = Profesionista.where(codigo_verificacion_email: params[:codigo_verificacion_email], 
                                            id: params[:id]).first
      if !@profesionista.nil?
        @profesionista.codigo_verificacion_email = ""
        @profesionista.email_verificado = 1
        if @profesionista.save
          @resultado = "Gracias por validar tu correo"
        else
          @resultado = "No se pudo guardar los cambios en el registro"
        end
      else
        @resultado = "Datos de validación no coinciden"
      end
    else
      @resultado = "No hay datos de verificación"
    end
  end
  
  # Llamado por usuario desde un link que se le envía por correo electrónico
  # El correo es enviado para clientes desde controlador inicio_cliente.verificaciones
  # La vista se encuentra en views/inicio/validar_email_cliente
  def validar_email_cliente
    if params[:codigo_verificacion_email].present? && params[:id].present?
      # buscar cliente. Si lo encuentra, actualiza validado y borra codigo_verificacion_email
      @cliente = Cliente.where(codigo_verificacion_email: params[:codigo_verificacion_email], 
                                            id: params[:id]).first
      if !@cliente.nil?
        @cliente.codigo_verificacion_email = ""
        @cliente.email_verificado = 1
        if @cliente.save
          @resultado = "Gracias por validar tu correo"
        else
          @resultado = "No se pudo guardar los cambios en el registro"
        end
      else
        @resultado = "Datos de validación no coinciden"
      end
    else
      @resultado = "No hay datos de verificación"
    end
  end
  
  # VISTA del perfíl de un profesionista
  def ver_profesionista
    @ver_fondo_gris = true # Solo estético para el color de fondo en layouts/application
    
    @profesionista = Profesionista.find_by(id: params[:id]) or mostrar_404
    @nombre_ciudad = ""
    @nombre_estado = ""
    if !@profesionista.id_ciudad_republica.nil? #Si profesionista tiene ciudad manifiesta
      ciudad = CiudadesRepublica.find(@profesionista.id_ciudad_republica)
      @nombre_ciudad = ciudad.descripcion
      @nombre_estado = EstadosRepublica.find(ciudad.id_estado).descripcion
    end
    
    @contrataciones = ProfesionistasXEventos.where(id_profesionista: @profesionista.id, 
              estado: ProfesionistasXEventos::ESTADO_CONTRATADO_EVALUADO).order(:fecha_calificacion => :desc)
  end
  
  
end
