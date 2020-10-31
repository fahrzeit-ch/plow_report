# frozen_string_literal: true

class UpdateReadStatusJob < ApplicationJob
  queue_as :default

  def perform(user_id, record_ids, clazz_name)
    begin
      user = User.find(user_id)
    rescue ActiveRecord::RecordNotFound
      return # We cant do anything when the user does not exist anymore
    end

    drives = get_clazz(clazz_name).with_viewstate(user).where(id: record_ids).reject(&:seen?)

    UserAction.track_list(user, drives)
  end

  def get_clazz(name)
    name.constantize
  end
end
