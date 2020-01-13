require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test "should get new" do
    get signup_path
    assert_response :success
  end

  test "should redirect edit when not logged in" do
    # ログインしていない状態で、edit_user_pathに飛ぶ
    get edit_user_path(@user)
    # flashの中身があって、login_urlに飛ぶ
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch user_path(@user),params: {user: {name: @user.name,
                          email: @user.email}}
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect edit when logged in as wrong user" do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect update when logged in as wrong user" do
    log_in_as(@other_user)
    patch user_path(@user)
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "successful edit with friendly forwarding" do
    # ログインしていない状態で編集ページに飛ぶ
    get edit_user_path(@user)
    # session[:forwarding_url]にはもといたページの情報が入っているべき
    assert_equal session[:forwarding_url], edit_user_url(@user)
    # ログインページに飛ばされ、@userとしてログインする
    log_in_as(@user)
    # 改めてさっきいたページに飛ぶ
    assert_redirected_to edit_user_url(@user)
    #session[:forwarding_url]には何も入っていないはず
    assert_nil session[:forwarding_url]
    name = "Foo Bar"
    email = "foo@bar.com"
    # 新しいnameとemailを更新する
    patch user_path(@user), params: {user: {name: name,
                              email: email,
                              password: "",
                              password_confirmation: ""}}
    # flashに更新完了のメッセージがあるか確認
    assert_not flash.empty?
    # user_showのページに飛ぶ
    assert_redirected_to @user
    # @userを更新した時に
    @user.reload
    # nameとemailが新しいものに変わっていることを確認
    assert_equal name, @user.name
    assert_equal email, @user.email
  end

  test "should redirect index when not logged in" do
    # ログインなしでusers_path(index)にアクセスした時
    get users_path
    # ログイン画面に飛ばす
    assert_redirected_to login_url
  end
end
