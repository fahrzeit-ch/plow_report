module CompanyMembersHelper
  def company_member
    @company_member || CompanyMember.new
  end

  def company_member_role_select_options
    CompanyMember::ROLES.map do |r|
      [t("activerecord.attributes.company_member.roles.#{r}"), r]
    end
  end

  def delete_member_confirm_message(member)
    if member == current_user
      t('confirm.company.delete_member_current_user')
    else
      t('confirm.company.delete_member')
    end
  end
end
