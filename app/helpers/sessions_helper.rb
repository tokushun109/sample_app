module SessionsHelper

  def log_in(user)
    session[:user_id] = user.id
  end

  def remember(user)
     user.remember
     cookies.permanent.signed[:user_id] = user.id
     cookies.permanent[:remember_token] = user.remember_token
  end

  def current_user?(user)
    # 渡されたユーザーがログイン済みユーザーであればtrueを返す
    user == current_user
  end

  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  def logged_in?
    !current_user.nil?
  end

  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

  def redirect_back_or(default)
    # sessionハッシュの中にログイン画面に行く前のページ情報を保存しておく
    redirect_to(session[:forwarding_url] || default)
    # sessionハッシュの:forwading_urlの値を削除する
    session.delete(:forwarding_url)
  end

  # アクセスしようとしたURLを覚えておく
  def store_location
    # もしHTTPリクエストがgetでされた場合、そのリクエストしたページのurlをsessionハッシュに
    # 覚えさせておく
    session[:forwarding_url] = request.original_url if request.get?
  end
end
