class AccountActivationsController < ApplicationController

# メールのリンク画面に飛んだら
  def edit
    # リンクに書いてあるparams[:email]からuserを特定し、
    user = User.find_by(email: params[:email])
    # そのuserがあって、activatedされてなくて、
    # acitvationキーの値がリンクに書いてあるparams[:id]と一致していた場合
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      # activatedをtrueにして、日付を登録
      user.activate
      # ログインする→sesson[:user_id]にuser.idを入れる
      log_in user
      flash[:success] = "Account activated!"
      redirect_to user
    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end
end
