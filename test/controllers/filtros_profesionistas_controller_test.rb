require 'test_helper'

class FiltrosProfesionistasControllerTest < ActionController::TestCase
  test "should get filtroA" do
    get :filtroA
    assert_response :success
  end

  test "should get filtroB" do
    get :filtroB
    assert_response :success
  end

  test "should get filtroC" do
    get :filtroC
    assert_response :success
  end

end
