require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

# 先にログインしないとindex画面が開けないため
  def setup
    @user = users(:michael)
  end

  test "index including pagination" do
    # @userとしてログインする
    log_in_as(@user)
    # index画面をリクエストする
    get users_path
    # index画面に飛ぶ
    assert_template 'users/index'
    # divクラスのpaginationクラスがあることを確認
    assert_select 'div.pagination'
    # pageは1ページ（30人分）表示されていて、全てuser.nameのテキスト部分がuser/showの
    # リンクにつながっている
    User.paginate(page: 1).each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
    end
  end
end
