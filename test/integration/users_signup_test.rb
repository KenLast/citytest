require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    @user       = users(:hawk)
		@other_user = users(:russell)
		@admin_user = users(:mark)
		ActionMailer::Base.deliveries.clear
  end


  test "invalid signup information" do
		log_in_as(@admin_user)
		get signup_path
    assert_no_difference 'User.count' do
      post signup_path, params: { user: { name:  "",
			                                   customerid: "INVALID",
                                         email: "user@invalid",
                                         password:              "foo",
                                         password_confirmation: "bar" } }
    end
    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'div.field_with_errors'
  end
	
  test "valid signup information with account activation" do
		log_in_as(@admin_user)
		get signup_path
    assert_difference 'User.count', 1 do
      post signup_path, params: { user: { name:  "Example User",
			                                   customerid: "VALID",
                                         email: "user@example.com",
                                         password:              "password",
                                         password_confirmation: "password" } }
    end
    # follow_redirect!
    # assert_template 'users/new'
		# assert_not flash.empty?
		# get root_path                    # KDA my signup stays on signup_path
		# delete logout_path               # KDA must log out from admin account

    assert_equal 0, ActionMailer::Base.deliveries.size   # KDA was 1. No mail now
    user = assigns(:user)
    assert user.activated
		
		get	root_path											# KDA my signup stays on signup page
		delete logout_path								# KDA must log out from admin account

		assert_not is_logged_in?
    # Try to log in before activation.
    log_in_as(user)
    assert is_logged_in?
  end

end