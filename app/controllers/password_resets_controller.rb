class PasswordResetsController < ApplicationController
  before_action :get_user,   only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]    # (1) への対応

  def new
  end

  def create
    # emailの送信formで保存先を:password_resetハッシュにしているため
    # :password_resetに:emailが入っている
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    # ＠userが存在する場合
    if @user
      # create_reset_digestメソッドを使う→おそらくreset_digestを作る
      # ＋でreset_send_atに現在事項を代入する
      @user.create_reset_digest
      # send_password_reset_emailメソッドを使う→おそらくreset用のemailを送る
      @user.send_password_reset_email
      # emailを送ったというメッセージをflashハッシュに保存する
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else
      flash.now[:danger] = "Email address not found"
      render 'new'
    end
  end

  def edit
  end

  def update
    # formに打ちこまれているpasswordの中身が空になっているか？
    if params[:user][:password].empty?                  # (3) への対応
      # パスワードが空だった時に空の文字列に対するデフォルトのメッセージを表示
      @user.errors.add(:password, :blank)
      render 'edit'
    # user_paramsが打ちこまれているか？
    elsif @user.update_attributes(user_params)          # (4) への対応
      # ログインする
      log_in @user
      # flashのハッシュのサクセスシンボルに”リセットできた”メッセージを入れる
      flash[:success] = "Password has been reset."
      redirect_to @user
    else
      # パスワードが無効だった場合、
      render 'edit'                                     # (2) への対応
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def get_user
    # hidden_fieldのparams[:email]の値を受け取って、userを特定
    # editでもupdateでも使えるようにどちらもparams[:email]に入れる
    @user = User.find_by(email: params[:email])
  end

  def valid_user
    # @userが存在する、@userは有効化されている、@userのreset_digestとemailのparams[:id]
    # が一致している→これに当てはまらないときhomeにリダイレクト
    unless (@user && @user.activated? &&
      @user.authenticated?(:reset, params[:id]))
      redirect_to root_url
    end

    # トークンの期限が切れたかを確認する
    def check_expiration
      # passwordのresetの期限が切れていないかの確認
      #
      if @user.password_reset_expired?
        flash[:danger] = "Password reset has expired."
        redirect_to new_password_reset_url
      end
    end
  end
end
