module CompanyMembersHelper
  def company_member
    @company_member || CompanyMember.new
  end

  def company_member_role_select_options
    CompanyMember::ROLES.map do |r|
      [t("activerecord.attributes.company_member.roles.#{r}"), r]
    end
  end
end
