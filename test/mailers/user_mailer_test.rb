require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test "account_activation" do
    # userをmichaelに設定
    user = users(:michael)
    # user.activation_tokenを新しく生成
    user.activation_token = User.new_token
    # UserMailerクラスのaccount_activationを実施
    # メールの宛先がuser.email、subjectが"Account activation"になる
    mail = UserMailer.account_activation(user)
    # mail.subjectの中身が"Account activation"になっている
    # account_activationメソッドを使っているため、なっているはず
    assert_equal "Account activation", mail.subject
    # mail.to（メールの宛先）がuser.emailになっている
    # account_activationメソッドを使っているため、なっているはず
    assert_equal [user.email], mail.to
    # application_mailer.rbでdefault from: "noreply@example.com"になっている
    assert_equal ["noreply@example.com"], mail.from
    # メールのHTMLのなかにuser.nameとuser.activation_tokenと、エスケープした
    # user.emailが含まれているか？
    assert_match user.name,               mail.body.encoded
    assert_match user.activation_token,   mail.body.encoded
    assert_match CGI.escape(user.email),  mail.body.encoded
  end

  test "password_reset" do
    # userをmichaelに設定
    user = users(:michael)
    # user.activation_tokenを新しく生成
    user.reset_token = User.new_token
    mail = UserMailer.password_reset(user)
    assert_equal "Password reset", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["noreply@example.com"], mail.from
    assert_match user.reset_token,   mail.body.encoded
    assert_match CGI.escape(user.email),  mail.body.encoded
  end

end
