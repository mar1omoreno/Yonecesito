# encoding: utf-8
class Profesionista < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates_presence_of :nombre, :apellido, on: :create
  
  validates :tel_celular, :on => :update, presence: true, length: {is: 10, message: "debe tener 10 digitos"},
      numericality: { only_integer: true, message: "solo números"}
  
  validates :tel_fijo, :on => :update, allow_blank: true, length: {is: 10, message: "debe tener 10 digitos"},
      numericality: { only_integer: true, message: "solo debe tener números"}
  
  SIZE_ESTRELLAS_1 = 1 # Tamaño de estrellas grande
  SIZE_ESTRELLAS_2 = 2 # Tamaño de estrellas para listas
  
  
  # Regresa HTML con estrellas según valor de cantidad y del tamaño definido por size
  def self.get_html_estrellas(cantidad, size = SIZE_ESTRELLAS_1)
    ancho_estrellas = 200 # ancho real de imagen de estrellas
    alto_estrellas = 50 # alto real de imagen de estrellas
    if size == SIZE_ESTRELLAS_2
      ancho_estrellas = 100
      alto_estrellas = 25
    end
    proporcion = cantidad / 5.to_f # de 5 estrellas máximo cuánto ocupa cantidad
    ancho = ancho_estrellas * proporcion # los pixeles que se pondrán de imagen estrellas
    style_calificacion = "height:#{alto_estrellas}px; width:#{ancho}px;"
    style_contenedor = "height:#{alto_estrellas}px; width:#{ancho_estrellas}px; text-align:left;"
    return '<span class="calificacion" style="'+style_contenedor+'"><span style="'+style_calificacion+'" ></span></span>'
  end
  
  # Regersa HTML con estrellas según la calificación del profesionista y usa el formato de tamaño según size
  def get_html_calificacion(size = SIZE_ESTRELLAS_1)
    promedio = 0
    if numero_calificaciones > 0
      promedio = numero_estrellas / numero_calificaciones.to_f # contadores en base de datos promediados
    end
    return Profesionista::get_html_estrellas(promedio, size)
  end
  
  def nombre_completo
    return ( (nombre || "") + " " + (apellido || "") ).titleize
  end
  
end