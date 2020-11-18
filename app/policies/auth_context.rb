# frozen_string_literal: true

class AuthContext
  extend Memoist

  attr_reader :user, :company, :driver

  def initialize(user, company, driver)
    @user = user
    @company = company
    @driver = driver
  end

  def company_admin_or_owner?(company = nil)
    user.company_admin_or_owner?(company || self.company)
  end
  memoize :company_admin_or_owner?

  def company_member?(company = nil)
    user.company_member?(company || self.company)
  end
  memoize :company_member?

  def is_demo(company = nil)
    user.demo_user_for?(company || self.company)
  end
  memoize :is_demo
end
