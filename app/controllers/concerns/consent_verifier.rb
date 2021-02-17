# frozen_string_literal: true

module ConsentVerifier
  extend ActiveSupport::Concern

  def check_consents
    return unless current_user&.force_consent_required?

    # Stored location may already been set in case of oauth signin
    unless has_stored_location?
      store_location_for(:user, request.original_url)
    end

    redirect_to edit_term_acceptances_path
  end

  # checks if there already is a stored location
  def has_stored_location?
    stored_location = stored_location_for(:user)

    if stored_location.blank?
      false
    else
      # store the location again because retrieving it with #stored_location_for(scope) does
      # also delete it from the session
      store_location_for(:user, stored_location)
      true
    end

  end
end
