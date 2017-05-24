require 'test_helper'

class MensajesClienteProfesionistasControllerTest < ActionController::TestCase
  test "should get mensajes" do
    get :mensajes
    assert_response :success
  end

end
