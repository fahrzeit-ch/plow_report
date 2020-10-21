class DriverApplication < ApplicationRecord
  has_secure_token
  belongs_to :user
  belongs_to :accepted_by, class_name: 'User', optional: true
  belongs_to :accepted_to, class_name: 'Company', optional: true

  validates :recipient, presence: true
  after_create :send_application

  def send_application
    DriverApplicationMailer.application_mail(id).deliver
  end

  def assign_to_id
    self.accepted_to.try(:id)
  end

  def assign_to_id=(id)
    self.accepted_to = Company.find(id)
  end

  def validate_already_accepted
    if accepted?
      errors[:base] << :already_accepted
      false
    else
      true
    end
  end

  def accepted?
    !accepted_at.nil?
  end

  # Accepts this application and adds the user as a driver
  # to the company given in +accepted_to+
  def accept(attrs = { accepted_by: nil })
    return unless validate_already_accepted
    transaction do
      accepted_to.add_driver(user)
      self.accepted_by = attrs.delete(:accepted_by)
      self.accepted_at = DateTime.current
      save
    end
  end

  def to_param
    token
  end
end
