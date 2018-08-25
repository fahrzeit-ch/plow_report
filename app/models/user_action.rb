# Tracks actions of a user on a record. This
# is primarilly to track views of a record, not to
# track changes!
class UserAction < ApplicationRecord
  belongs_to :user
  belongs_to :target, polymorphic: true

  def self.track_list(user, records)
    actions = records.map { |record| UserAction.new(user: user, target: record, activity: :list) }
    import actions
  end
end
