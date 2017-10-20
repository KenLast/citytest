require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @admin			= users(:mark)			# admin user
		@non_admin	= users(:russell)		# regular user
  end

	# successful display
  test "index" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
  end
	
  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end
	
	# redirection to root path due to non-administrator
	test "index fail because not administrator" do
		log_in_as(@non_admin)
		get users_path
		assert_redirected_to root_url
		end
end