module ApplicationHelper

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
    flash_messages = []
    flash.each do |type, message|
      type = 'success' if type == 'notice'
      type = 'error'   if type == 'alert'
      text = "toastr.#{type}('#{message}');"
      flash_messages << text.html_safe if message
    end
    flash_messages.join("\n").html_safe
  end

end
