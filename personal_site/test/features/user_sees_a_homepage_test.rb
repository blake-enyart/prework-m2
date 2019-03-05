require './test/test_helper'

class HomepageTest < CapybaraTestCase
  def test_user_can_see_the_homepage
    visit '/'

    assert_equal true, page.has_content?("Welcome!")
    assert_equal 200, page.status_code
  end

  def test_error_code_renders_correctly
    visit '/apple'

    assert_equal true, page.has_content?("Page not found")
    assert_equal 404, page.status_code
  end
end
