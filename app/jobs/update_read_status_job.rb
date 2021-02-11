# frozen_string_literal: true

class UpdateReadStatusJob < ApplicationJob
  discard_on ActiveRecord::RecordNotFound

  def perform(user_id, record_ids, clazz_name)
    user = User.find(user_id)
    drives = get_clazz(clazz_name).with_viewstate(user).where(id: record_ids).reject(&:seen?)

    UserAction.track_list(user, drives)
  end

  def get_clazz(name)
    name.constantize
  end
end
