module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private
    def authenticated?
      resume_session
    end

    def require_authentication
      resume_session || request_authentication
    end

    def resume_session
      Current.session ||= find_session_by_cookie
    end

    def find_session_by_cookie
      return unless cookies.signed[:session_id]

      session_record = Session.includes(:user).find_by(id: cookies.signed[:session_id])
      return session_record if session_record&.expires_at&.future?

      session_record&.destroy
      cookies.delete(:session_id)
      nil
    end

    def request_authentication
      session[:return_to_after_authenticating] = request.url
      redirect_to new_session_path
    end

    def after_authentication_url
      session.delete(:return_to_after_authenticating) || admin_root_url
    end

    def start_new_session_for(user)
      user.sessions.where("expires_at <= ?", Time.current).delete_all
      user.sessions.active.order(created_at: :desc).offset(4).destroy_all

      user.sessions.create!(
        user_agent: request.user_agent.to_s.first(500),
        ip_digest: PrivacyDigest.call(request.remote_ip, purpose: "session-ip")
      ).tap do |session|
        Current.session = session
        cookies.signed[:session_id] = {
          value: session.id,
          expires: session.expires_at,
          httponly: true,
          same_site: :lax,
          secure: Rails.env.production?
        }
      end
      user.update_column(:last_sign_in_at, Time.current)
    end

    def terminate_session
      Current.session&.destroy
      cookies.delete(:session_id)
    end
end
