# frozen_string_literal: true
module ApplicationHelper
  MESSAGE_TYPE_MAP = { 'notice' => 'success', 'alert' => 'error' }
  def current_path(params_overwrite)
    p = params.clone
    p.merge!(params_overwrite)
    p.permit!
    url_for(p)
  end

  def custom_bootstrap_flash
    "<script>#{js_flash}</script>".html_safe
  end

  def js_flash
    flash.map do |type, message|
      toastr_method = MESSAGE_TYPE_MAP[type] || type
      message.blank? ? '' : "toastr.#{toastr_method}('#{message}');".html_safe
    end.join("\n").html_safe
  end
end
