module DemoAccount

  extend ActiveSupport::Concern

  def demo_user_for?(company)
    return false unless respond_to? :companies_for_role
    return false if company.nil?

    return @_demo_member if @_demo_member
    @_demo_member = companies_for_role([CompanyMember::DEMO_ACCOUNT]).exists? company.id
  end

  # only force consents if the account is not a demo user.
  def force_consent_required?
    return false if demo_user?
    super
  end

  # Only require validation for terms if this is not a demo user.
  def term_validation_required?
    return false if demo_user?
    super
  end

  def demo_user?
    email == ENV["DEMO_ACCOUNT_EMAIL"]
  end

end