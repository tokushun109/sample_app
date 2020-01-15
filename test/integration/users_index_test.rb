require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

# 先にログインしないとindex画面が開けないため
  def setup
    @admin = users(:michael)
    @non_admin = users(:archer)
  end

  test "index including pagination" do
    # @userとしてログインする
    log_in_as(@admin)
    # index画面をリクエストする
    get users_path
    # index画面に飛ぶ
    assert_template 'users/index'
    # divクラスのpaginationクラスがあることを確認
    assert_select 'div.pagination'
    # 1ページ目に表示されるuserをfist_page_of_usersにまとめる
    first_page_of_users = User.where(activated: true).paginate(page: 1)
    # pageは1ページ（30人分）表示されていて、全てuser.nameのテキスト部分がuser/showの
    # リンクにつながっている
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      assert user.activated?
      # 表示されているuserが管理者である自分でなければ、
      unless user == @admin
        # deleteというテキストでリンクが表示される
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
    # @non_adminのdeleteリクエストを送った時、User.countは-1になる
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  test "index as non-admin" do
    # 管理者権限がないuserでログインした時
    log_in_as(@non_admin)
    # index画面をリクエストすると
    get users_path
    # deleteと書いているaのタグは存在しない
    assert_select 'a', text: 'delete', count: 0
  end

end
