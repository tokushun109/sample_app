require 'test_helper'

class SessionsHelperTest < ActionView::TestCase
  def setup
    # fixtureに準備したmichaelを使用
    @user = users(:michael)
    # michaelの記憶ダイジェストを生成する＋coockieにuser_idと記憶トークンを登録
    remember(@user)
  end

  test "current_user returns right user when session is nil" do
    assert_equal @user, current_user
    assert is_logged_in?
  end

  test "current_user returns nil when remember digest is wrong" do
  # :remember_digestに、新しく生成したremember_tokenのdigestを入れたら、cookiesに入っている
  # remember_tokenとは異なり、authenticaterd?メソッドがfalseを返す
  # そしたらcurrent_userには何も入らないようになっているか
    @user.update_attribute(:remember_digest, User.digest(User.new_token))
    assert_nil current_user
  end
end
