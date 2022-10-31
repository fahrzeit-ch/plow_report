# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record, :auth_context

  def initialize(auth_context, record)
    raise Pundit::NotAuthorizedError, I18n.t("pundit.not_logged_in") unless auth_context.user
    @auth_context = auth_context
    @user = auth_context.user
    @record = record
  end

  def index?
    false
  end

  def show?
    scope.where(id: record.id).exists?
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
    Pundit.policy_scope!(auth_context, record.class)
  end

  class Scope
    attr_reader :user, :scope, :auth_context

    def initialize(auth_context, scope)
      raise Pundit::NotAuthorizedError, I18n.t("pundit.not_logged_in") unless auth_context.user
      @auth_context = auth_context
      @user = auth_context.user
      @scope = scope
    end

    def resolve
      scope
    end
  end

  protected
    def company_admin_or_owner?(company = nil)
      auth_context.company_admin_or_owner?(company)
    end

    def company_member?(company = nil)
      auth_context.company_member?(company)
    end

    def is_demo(company = nil)
      auth_context.is_demo(company)
    end

    def is_app_login(company = nil)
      auth_context.app_login?(company)
    end
end
