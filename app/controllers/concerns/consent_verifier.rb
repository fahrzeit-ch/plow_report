module ConsentVerifier
  extend ActiveSupport::Concern

  def check_consents
    return unless current_user
    if current_user.force_consent_required?
      redirect_to edit_term_acceptances_path
    end
  end
end