require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest

  def setup
    @user       = users(:hawk)
		@other_user = users(:russell)
		@admin_user = users(:mark)
  end

  test "layout links" do
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
		get contact_path
		assert_select "title", full_title("Contact")
		log_in_as(@admin_user)
		get signup_path
		assert_select "title", full_title("Sign up")
  end
end
