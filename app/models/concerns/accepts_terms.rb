module AcceptsTerms

  extend ActiveSupport::Concern

  included do
    has_many :term_acceptances, dependent: :destroy
    has_many :accepted_terms, class_name: 'PolicyTerm', through: :term_acceptances, source: :policy_term
    has_many :outdated_acceptances, -> { require_update }, class_name: 'TermAcceptance'
    has_many :terms_with_updates, through: :outdated_acceptances, source: :policy_term

    after_save :save_terms
    validate :required_terms_accepted, if: :term_validation_required?
    validate :updated_terms_accepted, if: :term_validation_required?
  end

  attr_accessor :skip_term_validation

  def save_terms
    accepted_terms << PolicyTerm.where(key: terms)
  end

  def required_terms_accepted
    req_terms = PolicyTerm.where(required: true).pluck(:key)

    acceptances = accepted_terms.pluck(:key) + terms
    unless (req_terms - acceptances).length == 0
      errors.add(:base, :consent_required)
    end
  end

  def updated_terms_accepted
    updated_terms = terms_with_updates.required.pluck(:key)
    unless (updated_terms - terms).length == 0
      errors.add(:base, :new_consent_required)
    end
  end

  # Returns all Terms that were not accepted by the user yet
  def unchecked_terms
    if persisted?
      PolicyTerm.joins("LEFT JOIN term_acceptances as ta
                        ON policy_terms.id = ta.policy_term_id
                        AND ta.user_id = '#{self.id}'
                        AND ta.invalidated_at is NULL").where('ta.policy_term_id is null')
    else
      PolicyTerm.all
    end
  end

  # Attr writer for term acceptance checkboxes
  # Accepts an array of term keys. For each key,
  # a term_acceptance will be created after save-
  # term_types can also be a Hash from checkbox params:
  #   { :privacy_policy => 1, :age => 1 }
  def terms=(term_types)
    @terms = extract_keys term_types
  end

  def terms
    @terms ||= []
  end

  # Extracts the keys from a hash
  def extract_keys(params)
    if params.is_a? Hash
      params.keys
    elsif params.is_a? Array
      params
    else
      raise ArgumentError.new "Can not extract keys from type: #{params.class.name}"
    end
  end

  def term_validation_required?
    return false if skip_term_validation
    new_record? || terms_with_updates.exists? || unchecked_terms.exists?
  end

end