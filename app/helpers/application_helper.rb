# frozen_string_literal: true
module ApplicationHelper
  MESSAGE_TYPE_MAP = { 'notice' => 'success', 'alert' => 'error' }

  def initials(text)
    text.split(' ').map{ |n| n[0] }.join
  end

  def current_path(params_overwrite, clear_params = false)
    p = clear_params ? ActionController::Parameters.new : params.clone
    p.merge!(params_overwrite)
    p.permit!
    url_for(p)
  end

  def custom_bootstrap_flash
    javascript_tag nonce: true do
      js_flash
    end.html_safe
  end

  def js_flash
    flash.map do |type, message|
      toastr_method = MESSAGE_TYPE_MAP[type] || type
      message.blank? ? '' : "toastr.#{toastr_method}('#{message}');".html_safe
    end.join("\n").html_safe
  end

  def distance_of_date_in_words_to_now(date)
    key = ''
    distance = nil
    if date == Date.current
      key = 'today'
    elsif Date.tomorrow == date
      key = 'tomorrow'
    else
      key = 'in_x_days'
      distance = (date - Date.current).to_i
    end
    I18n.t(key, distance: distance)
  end

  def is_processing(icon_only = false)
    content = "<i class='fa fa-refresh fa-spin'>
          </i>".html_safe
    content << " #{t('common.please_wait')}".html_safe unless icon_only
    content
  end

end
