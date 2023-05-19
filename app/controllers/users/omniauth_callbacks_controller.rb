class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :google_oauth2

  def google_oauth2
      @user = User.from_omniauth(request.env['omniauth.auth'])

      if @user && @user.persisted?
        flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: 'Google'
        session[:user_id] = @user.id
        sign_in_and_redirect @user, event: :authentication
      else
        email = request.env['omniauth.auth'].info.email
        flash[:warning] = "No user #{email} configured; contact the administrator"
        redirect_to new_user_session_path and return
      end
  end
end
