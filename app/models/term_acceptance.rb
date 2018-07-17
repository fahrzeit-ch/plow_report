class TermAcceptance < ApplicationRecord
  belongs_to :user
  belongs_to :policy_term
  before_create :set_term_version
  after_create :invalidate_previous

  default_scope { where(invalidated_at: nil) }

  def needs_update
    created_at < term.updated_at
  end

  # Returns all acceptances which have an older acceptance
  # date than the terms last update
  def self.require_update
    joins(:policy_term).where('term_acceptances.created_at < policy_terms.updated_at')
  end

  private
  def set_term_version
    self.term_version = policy_term.revisions.last.version
  end

  def invalidate_previous
    self.class.where(policy_term_id: self.policy_term_id, user_id: self.user_id).where.not(id: self.id)
      .update_all(invalidated_at: Time.now.utc)
  end
end