# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150620074248) do

  create_table "ciudades_republica", force: true do |t|
    t.integer "id_estado",               null: false
    t.string  "descripcion", limit: 150, null: false
  end

  create_table "clientes", force: true do |t|
    t.string   "email",                                 default: "", null: false
    t.string   "encrypted_password",                    default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider"
    t.string   "uid"
    t.string   "nombre"
    t.string   "apellido"
    t.string   "sobre_ti",                  limit: 300
    t.string   "tel_fijo"
    t.string   "tel_celular"
    t.string   "direccion",                 limit: 100
    t.string   "cp",                        limit: 5
    t.string   "sexo",                      limit: 1
    t.date     "fecha_nacimiento"
    t.integer  "activo",                    limit: 1
    t.string   "clave"
    t.integer  "id_ciudad_republica"
    t.string   "codigo_verificacion_email", limit: 50
    t.integer  "email_verificado",          limit: 1
  end

  add_index "clientes", ["reset_password_token"], name: "index_clientes_on_reset_password_token", unique: true, using: :btree

  create_table "creditos", force: true do |t|
    t.integer   "id_profesionista",                           null: false
    t.timestamp "fecha_adquisicion",                          null: false
    t.integer   "creditos_adquiridos",                        null: false
    t.float     "costo",               limit: 53,             null: false
    t.integer   "valido",              limit: 1,  default: 0
    t.string    "codtran_pademobile",  limit: 40
  end

  add_index "creditos", ["id_profesionista"], name: "fk_credito_profesionista1_idx", using: :btree

  create_table "estados_republica", force: true do |t|
    t.string "descripcion", limit: 50, null: false
  end

  create_table "eventos", force: true do |t|
    t.integer "id_cliente",                                       null: false
    t.integer "id_tipo_trabajo",                                  null: false
    t.text    "plantilla_json_completa",                          null: false
    t.string  "descripcion",             limit: 1000,             null: false
    t.integer "urgencia_necesidad",      limit: 1,                null: false
    t.date    "fecha",                                            null: false
    t.integer "hora"
    t.integer "tiempo",                  limit: 1
    t.string  "direccion_completa",      limit: 150,              null: false
    t.string  "colonia",                 limit: 45,               null: false
    t.string  "cp",                      limit: 6
    t.integer "id_ciudad_republica",                              null: false
    t.integer "id_estado_republica",                              null: false
    t.string  "correo_electronico",      limit: 100,              null: false
    t.string  "telefono_movil",          limit: 20
    t.string  "telefono_fijo",           limit: 20
    t.integer "presupuesto_por_llamada", limit: 1,    default: 0, null: false
    t.integer "estado",                               default: 1, null: false
    t.integer "evaluacion_estado"
    t.string  "otra_razon",              limit: 200
    t.date    "fecha_alta"
  end

  add_index "eventos", ["id_cliente"], name: "fk_evento_cliente1_idx", using: :btree
  add_index "eventos", ["id_tipo_trabajo"], name: "fk_evento_tipo_trabajo1_idx", using: :btree

  create_table "fotos_cliente", force: true do |t|
    t.integer "id_cliente",            null: false
    t.string  "photo",      limit: 50
    t.string  "extension",  limit: 50
  end

  add_index "fotos_cliente", ["id_cliente"], name: "fk_foto_x_cliente_cliente_idx", using: :btree

  create_table "fotos_profesionista", force: true do |t|
    t.integer "id_profesionista", null: false
  end

  add_index "fotos_profesionista", ["id_profesionista"], name: "fk_foto_x_profesionista_profesionista1_idx", using: :btree

  create_table "mensajes", force: true do |t|
    t.integer  "id_profesionista_evento",                         null: false
    t.integer  "id_profesionista",                                null: false
    t.integer  "id_cliente",                                      null: false
    t.datetime "fecha_hora"
    t.float    "cotizacion",              limit: 53
    t.string   "titulo",                  limit: 100,             null: false
    t.text     "contenido",                                       null: false
    t.integer  "estado",                  limit: 1,   default: 0, null: false
    t.integer  "fuente",                  limit: 1,   default: 0, null: false
  end

  add_index "mensajes", ["id_cliente"], name: "fk_mensaje_cliente1_idx", using: :btree
  add_index "mensajes", ["id_profesionista"], name: "fk_mensaje_profesionista1_idx", using: :btree
  add_index "mensajes", ["id_profesionista_evento", "id_profesionista", "id_cliente"], name: "mensajes_busqueda_index", using: :btree
  add_index "mensajes", ["id_profesionista_evento"], name: "fk_mensaje_profesionista_x_evento1_idx", using: :btree

  create_table "profesionistas", force: true do |t|
    t.string   "email",                                 default: "", null: false
    t.string   "encrypted_password",                    default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "nombre"
    t.string   "apellido"
    t.integer  "id_ciudad_republica"
    t.string   "tel_fijo"
    t.string   "tel_celular"
    t.string   "empresa"
    t.string   "sobre_empresa",             limit: 300
    t.date     "fecha_nacimiento"
    t.string   "sexo",                      limit: 1
    t.string   "pagina_web",                limit: 70
    t.string   "direccion",                 limit: 100
    t.string   "cp",                        limit: 5
    t.integer  "email_verificado",          limit: 1
    t.string   "codigo_verificacion_email", limit: 50
    t.integer  "creditos",                              default: 0,  null: false
  end

  add_index "profesionistas", ["email"], name: "index_profesionistas_on_email", unique: true, using: :btree
  add_index "profesionistas", ["reset_password_token"], name: "index_profesionistas_on_reset_password_token", unique: true, using: :btree

  create_table "profesionistas_x_eventos", force: true do |t|
    t.integer   "id_evento",                                    null: false
    t.integer   "id_profesionista",                             null: false
    t.timestamp "fecha_aplicacion",                             null: false
    t.integer   "creditos_consumidos",              default: 1, null: false
    t.integer   "estado",               limit: 1,   default: 0, null: false
    t.integer   "calificacion_cliente", limit: 1
    t.string    "comentarios_cliente",  limit: 500
    t.integer   "motivo_rechazo",       limit: 1
    t.string    "otro_motivo",          limit: 200
    t.datetime  "fecha_calificacion"
  end

  add_index "profesionistas_x_eventos", ["id_evento"], name: "fk_profesionistas_x_eventos_evento1_idx", using: :btree
  add_index "profesionistas_x_eventos", ["id_profesionista"], name: "fk_profesionista_x_evento_profesionista1_idx", using: :btree

  create_table "profesionistas_x_trabajos", id: false, force: true do |t|
    t.integer "id_tipo_trabajo",  null: false
    t.integer "id_profesionista", null: false
  end

  add_index "profesionistas_x_trabajos", ["id_profesionista"], name: "fk_profesionista_x_trabajo_profesionista1_idx", using: :btree

  create_table "tipos_trabajo", force: true do |t|
    t.string "categoria",      limit: 50,  null: false
    t.string "servicio",       limit: 100, null: false
    t.text   "plantilla_json",             null: false
    t.string "nombre_imagen",  limit: 50
  end

end
