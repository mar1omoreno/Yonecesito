module ApplicationHelper

  # Definido para obtener datos de omniauth 
  def get_email_oauth
    if session[:omniauth_data]
      session[:omniauth_data][:email]
    else
      "" #Sin información
    end
  end
  
  # Regresa el :valor texto según un :id en una colección de hashes [{valor: 'texto', id: 1}, {valor:'texto2', id: 2},...]
  # Considera que arreglo tiene una colección de hashes los cuales tienen llaves :valor y :id
  def get_valor_lista(arreglo, id)
    hash = arreglo.detect {|u| u[:id] == id } 
    return hash[:valor]
  end
  
  def get_valor_urgencia(arreglo, id)
    hash = arreglo.detect {|u| u[:id] == id } 
    return hash[:valor]
  end
  
  # Definido para obtener username de oauth
  #def get_username_oauth
  #  if session[:omniauth_data]
  #    session[:omniauth_data][:username]
  #  else
  #    "" #Sin información
  #  end
  #end
  
end
