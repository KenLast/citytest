require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  def setup
    @user = users(:hawk)
		@order = @user.orders.first

		@product = @order.lineitems.build(product_id: 10, quantity: 3)
  end

  test "should be valid" do
    assert @product.valid?
  end
=begin
  test "order id should be present" do
    @product.order_id = nil
#		puts @product.attributes.to_yaml
    assert_not @product.valid?
  end
=end
end
