module ConsentVerifier
  extend ActiveSupport::Concern

  def check_consents
    return unless current_user
    if current_user.unchecked_terms.required.any? || current_user.outdated_acceptances.any?
      redirect_to edit_term_acceptances_path
    end
  end
end