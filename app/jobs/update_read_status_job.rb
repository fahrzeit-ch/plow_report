class UpdateReadStatusJob < ApplicationJob
  queue_as :default

  def perform(user_id, drive_ids)
    begin
      user = User.find(user_id)
    rescue ActiveRecord::RecordNotFound => e
      return # We cant do anything when the user does not exist anymore
    end

    drives = Drive.with_viewstate(user).where(id: drive_ids).reject(&:seen?)

    UserAction.track_list(user, drives)
  end
end
