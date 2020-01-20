require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest

  def setup
    # メールの件数を0件にしておく
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end

  test "password resets" do
    # パスワードの再設定を行うために,emailを送信するpathのリクエストを送る
    get new_password_reset_path
    #　ビューがpassword_resets/new画面になる
    assert_template 'password_resets/new'
    # メールアドレスが無効
    post password_resets_path, params: { password_reset: { email: "" } }
    # "Email address not found"のフラッシュが入っているか？
    assert_not flash.empty?
    # もう一度ビューがpassword_resets/new画面になるか？
    assert_template 'password_resets/new'
    # メールアドレスが有効
    post password_resets_path,
         params: { password_reset: { email: @user.email } }
    # @user.reset_digestはフォームを送っただけのとき、
    # @user.reload.reset_digestはリロードして新しいdigestになったもの
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    # 正しいポストリクエストが送られた場合、確認メールが送信される
    assert_equal 1, ActionMailer::Base.deliveries.size
    # "Email sent with password reset instructions"というフラッシュが入っているか？
    assert_not flash.empty?
    # root_urlに飛ばせようとするか
    assert_redirected_to root_url
    # パスワード再設定フォームのテスト
    # userはpassword_resetのcreateで扱っている@userの中身
    # reset_tokenもreset_digestも扱える
    user = assigns(:user)
    # メールアドレスが無効
    # emailが載っていないリンクからedit_password_pathに飛ぶ
    get edit_password_reset_path(user.reset_token, email: "")
    # リンクが間違っている場合、root_urlに飛ぶ
    assert_redirected_to root_url
    # 無効なユーザー
    # activatedをtrueからfalseにしてみる→無効なuserを作成するため
    user.toggle!(:activated)
    # 正しいリンクを使ってedit_password_reset_pathに飛ぶ
    get edit_password_reset_path(user.reset_token, email: user.email)
    # activatedされていないため、root_urlに飛ぶ
    assert_redirected_to root_url
    # 今度はactivatedをfalseからtrueする
    user.toggle!(:activated)
    # メールアドレスが有効で、トークンが無効
    get edit_password_reset_path('wrong token', email: user.email)
    # メールアドレスが無効な為、root_urlに戻される
    assert_redirected_to root_url
    # メールアドレスもトークンも有効
    get edit_password_reset_path(user.reset_token, email: user.email)
    # password_resets/edit（パスワード再設定画面に飛ぶ）
    assert_template 'password_resets/edit'
    # inputのnameにemail、typeにhidden、valueにemailが載っているか
    # つまりhiddenフォームでemailをupdateに送れているか？
    assert_select "input[name=email][type=hidden][value=?]", user.email
    # 無効なパスワードとパスワード確認
    # updateにフォームの値として異なるパスワードを入れる
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:              "foobaz",
                            password_confirmation: "barquux" } }
    # #error_explanationのdivが出る（エラーが出る）
    assert_select 'div#error_explanation'
    # パスワードが空
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:              "",
                            password_confirmation: "" } }
    # #error_explanationのdivが出る（エラーが出る）
    assert_select 'div#error_explanation'
    # 有効なパスワードとパスワード確認
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:              "foobaz",
                            password_confirmation: "foobaz" } }
    # ログインする
    assert is_logged_in?
    # flashの中身確かめる（"Password has been reset."が入っている）
    assert_not flash.empty?
    # user#show画面に飛ばそうとする
    assert_redirected_to user
  end

  test "expired token" do

    get new_password_reset_path
    post password_resets_path,
         params: { password_reset: { email: @user.email } }

    @user = assigns(:user)
    @user.update_attribute(:reset_sent_at, 3.hours.ago)
    patch password_reset_path(@user.reset_token),
          params: { email: @user.email,
                    user: { password:              "foobar",
                            password_confirmation: "foobar" } }
    assert_response :redirect
    follow_redirect!
    assert_match "Password reset has expired.", response.body
  end
end
