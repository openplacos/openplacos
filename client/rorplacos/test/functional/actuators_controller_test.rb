require 'test_helper'

class ActuatorsControllerTest < ActionController::TestCase
  setup do
    @actuator = actuators(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:actuators)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create actuator" do
    assert_difference('Actuator.count') do
      post :create, :actuator => @actuator.attributes
    end

    assert_redirected_to actuator_path(assigns(:actuator))
  end

  test "should show actuator" do
    get :show, :id => @actuator.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @actuator.to_param
    assert_response :success
  end

  test "should update actuator" do
    put :update, :id => @actuator.to_param, :actuator => @actuator.attributes
    assert_redirected_to actuator_path(assigns(:actuator))
  end

  test "should destroy actuator" do
    assert_difference('Actuator.count', -1) do
      delete :destroy, :id => @actuator.to_param
    end

    assert_redirected_to actuators_path
  end
end
