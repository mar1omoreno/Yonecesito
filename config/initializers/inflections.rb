# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.acronym 'RESTful'
# end
ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'cliente', 'clientes'
  inflect.irregular 'profesionista', 'profesionistas'
  inflect.irregular 'estado_republica', 'estados_republica'
  inflect.irregular 'ciudad_republica', 'ciudades_republica'
  inflect.irregular 'profesionista_x_evento', 'profesionistas_x_eventos'
  inflect.irregular 'profesionista_x_trabajo', 'profesionistas_x_trabajos'
  inflect.irregular 'tipo_trabajo', 'tipos_trabajo'
  inflect.irregular 'evento', 'eventos'
  inflect.irregular 'credito', 'creditos'
  inflect.irregular 'mensaje', 'mensajes'
  inflect.irregular 'foto_profesionista', 'fotos_profesionista'
  inflect.irregular 'foto_cliente', 'fotos_cliente'
end