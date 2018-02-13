class Company < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :options, presence: true

  has_many :company_members, dependent: :destroy

  def add_member(user, role)
    company_members.create(user: user, role: role )
  end

  # Returns companies that the given user_id has a membership with
  def self.with_member(user_id)
    joins(:company_members).where(company_members: {user_id: user_id})
  end

end
