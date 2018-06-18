class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    raise Pundit::NotAuthorizedError, I18n.t('pundit.not_logged_in') unless user
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    scope.where(:id => record.id).exists?
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      raise Pundit::NotAuthorizedError, I18n.t('pundit.not_logged_in') unless user

      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end

  protected

  def company_admin_or_owner?(company)
    return false if company.nil?
    user.companies_for_role([CompanyMember::ADMINISTRATOR, CompanyMember::OWNER]).exists? company.id
  end

  def company_member?(company)
    return false if company.nil?
    user.companies.exists? company.id
  end
end