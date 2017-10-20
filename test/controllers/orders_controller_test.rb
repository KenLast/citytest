require 'test_helper'

class OrdersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @order = orders(:orange)
  end

  test "should redirect create when not logged in" do
    assert_no_difference 'Order.count' do
      post orders_path, params: { order: { note: "Lorem ipsum", cuisine: "Thai" } }
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference 'Order.count' do
      delete order_path(@order)
    end
    assert_redirected_to login_url
  end
	
	test "should create one order" do
		@user = users(:hawk)
		log_in_as(@user)
		get user_path(@user)
	  assert_difference 'Order.count', 1 do
			post orders_path, params: { order: { note: "Lorem ipsum", cuisine: "Thai" } }
    end
		assert_redirected_to @user
	end
end