class FiltrosProfesionistasController < ApplicationController
  protect_from_forgery
  before_action :validar_login_profesionista #heredado en application_controller.rb
    
  #skip_before_filter :verify_authenticity_token #necesario cuando filtros no usaban post con validación
  
  
  def filtroA
    #Consultamos categorías (select distinct)
    @categorias = TiposTrabajo.uniq.pluck(:categoria)
  end

  def filtroB
    @categoria = nil #nada aún
    @categoria = session[:categoria_registro_profesionista] unless session[:categoria_registro_profesionista].nil?
    if params[:seleccion] != nil && params[:seleccion][:categoria] != nil
      @categoria = params[:seleccion][:categoria]
    end
    if @categoria.nil?
      logger.info "no hay categoría seleccionada así que se intentó venir a esta página de forma inesperada"
      redirect_to filtros_profesionistas_filtroA
    else
      session[:categoria_registro_profesionista] = @categoria #se guarda valor más reciente
    end
    
    logger.info "filtroB recibe categoría "+@categoria
    
    #@servicios = TiposTrabajo.uniq.pluck(:categoria , :servicio)
    #@servicios = TiposTrabajo.uniq.pluck(:servicio)
    @tiposTrabajo = TiposTrabajo.where(categoria: @categoria)
    
    ##guardaremos el primer filtro validado 
      
  end


  def filtroC
    @categoria = params[:servicios][:categoria] if hay_parametro(:servicios, :categoria) #categoría recibida desde filtroA como invisible en filtroB
    if params[:servicio]
      @idTiposTrabajoEscogidos = params[:servicio] #tipos de trabajo escogidos en filtroB
      # Se borran viejos tipos de trabajo
      ProfesionistasXTrabajos.delete_all(id_profesionista: current_profesionista.id)
      # Se agregan nuevos tipos de trabajo
      @idTiposTrabajoEscogidos.each do |idTipo|
        reg = ProfesionistasXTrabajos.create(id_tipo_trabajo: idTipo, id_profesionista: current_profesionista.id)
        reg.save
      end
      # TODO registrar ¿categoría?
    end
  end
  
  def final
    current_profesionista.tel_celular = params[:profesionista][:tel_celular] if hay_parametro(:profesionista)
    current_profesionista.tel_fijo = params[:profesionista][:tel_fijo] if hay_parametro(:profesionista, :tel_fijo)
    current_profesionista.empresa = params[:profesionista][:empresa] if hay_parametro(:profesionista, :empresa)
    
    if current_profesionista.save
      redirect_to inicio_profesionista_index_path
    else
      respond_to do |format| format.html {render "filtroC"} end
    end
  end
end
