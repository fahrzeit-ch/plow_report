class TermAcceptance < ApplicationRecord
  belongs_to :user
  belongs_to :policy_term

  def needs_update
    created_at < term.updated_at
  end

  # Returns all acceptances which have an older acceptance
  # date than the terms last update
  def self.require_update
    joins(:policy_term).where('term_acceptances.created_at < policy_terms.updated_at')
  end
end