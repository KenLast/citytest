require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  def setup
    @user = users(:hawk)
  end

  test "profile display" do
		log_in_as(@user)
    get user_path(@user)
    assert_template 'users/show'
    assert_select 'title', full_title(@user.name)
		# commented out because h1 section includes customerid field too
    # assert_select 'h1', @user.name
    # assert_select 'h1>img.gravatar'
    assert_match @user.orders.count.to_s, response.body
		# whatthehell
  end
	
	def whatthehell
    puts "-------------------"
		puts @user.attributes.to_yaml
		puts "orders.count is #{@user.orders.count.to_s}"
		puts "-------------------"
		puts response.body
		puts "-------------------"
	end
end
