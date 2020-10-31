# frozen_string_literal: true

module ConsentVerifier
  extend ActiveSupport::Concern

  def check_consents
    return unless current_user
    if current_user.force_consent_required?
      # Stored location may already been set in case of oauth signin
      location = stored_location_for(:user)
      if location.blank?
        store_location_for(:user, request.original_url)
      else
        store_location_for(:user, location)
      end

      redirect_to edit_term_acceptances_path
    end
  end
end
