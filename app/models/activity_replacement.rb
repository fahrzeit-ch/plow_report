# frozen_string_literal: true

class ActivityReplacement
  include ActiveModel::Model

  attr_accessor :old_activity_id, :new_activity_id
  validates :old_activity_id, :new_activity_id, presence: true

  def old_activity
    Activity.find_by(id: old_activity_id)
  end

  def new_activity
    Activity.find_by(id: new_activity_id)
  end
end