ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  form_fields = %w(textarea input select)
  html = html_tag
  elements = Nokogiri::HTML::DocumentFragment.parse(html_tag).css form_fields.join(', ')
  elements.each do |e|

    if instance.error_message.kind_of?(Array)
      html = %( #{html_tag}<div class="invalid-feedback">#{instance.error_message.uniq.join(', ')}</div>).html_safe
    else
      html = %(#{html_tag}<div class="invalid-feedback">#{instance.error_message}</div>).html_safe
    end
  end
  html
end