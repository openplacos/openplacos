require 'test_helper'

class SensorsControllerTest < ActionController::TestCase
  setup do
    @sensor = sensors(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sensors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sensor" do
    assert_difference('Sensor.count') do
      post :create, :sensor => @sensor.attributes
    end

    assert_redirected_to sensor_path(assigns(:sensor))
  end

  test "should show sensor" do
    get :show, :id => @sensor.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @sensor.to_param
    assert_response :success
  end

  test "should update sensor" do
    put :update, :id => @sensor.to_param, :sensor => @sensor.attributes
    assert_redirected_to sensor_path(assigns(:sensor))
  end

  test "should destroy sensor" do
    assert_difference('Sensor.count', -1) do
      delete :destroy, :id => @sensor.to_param
    end

    assert_redirected_to sensors_path
  end
end
