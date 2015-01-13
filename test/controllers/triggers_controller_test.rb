require 'test_helper'

class TriggersControllerTest < ActionController::TestCase
  setup do
    @trigger = triggers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:triggers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create trigger" do
    assert_difference('Trigger.count') do
      post :create, trigger: { day: @trigger.day, experiment_id: @trigger.experiment_id, friday: @trigger.friday, hour: @trigger.hour, interval: @trigger.interval, monday: @trigger.monday, repeat: @trigger.repeat, saturday: @trigger.saturday, second: @trigger.second, sunday: @trigger.sunday, thursday: @trigger.thursday, time_of_day: @trigger.time_of_day, timer: @trigger.timer, tuesday: @trigger.tuesday, wednesday: @trigger.wednesday }
    end

    assert_redirected_to trigger_path(assigns(:trigger))
  end

  test "should show trigger" do
    get :show, id: @trigger
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @trigger
    assert_response :success
  end

  test "should update trigger" do
    patch :update, id: @trigger, trigger: { day: @trigger.day, experiment_id: @trigger.experiment_id, friday: @trigger.friday, hour: @trigger.hour, interval: @trigger.interval, monday: @trigger.monday, repeat: @trigger.repeat, saturday: @trigger.saturday, second: @trigger.second, sunday: @trigger.sunday, thursday: @trigger.thursday, time_of_day: @trigger.time_of_day, timer: @trigger.timer, tuesday: @trigger.tuesday, wednesday: @trigger.wednesday }
    assert_redirected_to trigger_path(assigns(:trigger))
  end

  test "should destroy trigger" do
    assert_difference('Trigger.count', -1) do
      delete :destroy, id: @trigger
    end

    assert_redirected_to triggers_path
  end
end
