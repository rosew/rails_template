require 'test_helper'

class UserTest < ActiveSupport::TestCase

  # Before every test
  setup do
    user = users(:one)
  end
  
  test "fixture is valid" do
    assert @user.valid?
  end

end
