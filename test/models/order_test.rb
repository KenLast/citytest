require 'test_helper'

class OrderTest < ActiveSupport::TestCase
	
	def setup
		@user = users(:hawk)
		# This code not idiomatically correct.
		# @order = Order.new(note: "Here ia a test order", user_id: @user.id)
		@order = @user.orders.build(note: "Here is a test order", name: "test order", cuisine: @user.cuisine)
		x = @order.lineitems.build(quantity: 3, product_id: 10, selum: "pound")
	end
	
	test "should be valid" do
		assert @order.valid?
	end
	
	test "user id should be present" do
		@order.user_id = nil
		assert_not @order.valid?
	end
	
	test "order should be most recent first" do
		assert_equal orders(:most_recent), Order.first
	end
end
