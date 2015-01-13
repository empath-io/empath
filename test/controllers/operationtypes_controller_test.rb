require 'test_helper'

class OperationtypesControllerTest < ActionController::TestCase
  setup do
    @operationtype = operationtypes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:operationtypes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create operationtype" do
    assert_difference('Operationtype.count') do
      post :create, operationtype: { content: @operationtype.content, name: @operationtype.name, type: @operationtype.type }
    end

    assert_redirected_to operationtype_path(assigns(:operationtype))
  end

  test "should show operationtype" do
    get :show, id: @operationtype
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @operationtype
    assert_response :success
  end

  test "should update operationtype" do
    patch :update, id: @operationtype, operationtype: { content: @operationtype.content, name: @operationtype.name, type: @operationtype.type }
    assert_redirected_to operationtype_path(assigns(:operationtype))
  end

  test "should destroy operationtype" do
    assert_difference('Operationtype.count', -1) do
      delete :destroy, id: @operationtype
    end

    assert_redirected_to operationtypes_path
  end
end
