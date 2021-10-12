# frozen_string_literal: true

module ApplicationHelper
  MESSAGE_TYPE_MAP = { "notice" => "success", "alert" => "error" }

  def initials(text)
    text.split(" ").map { |n| n[0] }.join
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

  def label_with_help_for(klass, attribute)
    help_translation_key = "#{klass.i18n_scope}.attributes.#{klass.model_name.i18n_key}.#{attribute}_help_html"
    "#{klass.human_attribute_name(attribute)} #{help_icon(help_translation_key)}".html_safe
  end

  def help_icon(translation_key)
    tag.a tabindex: "0", class: "no-propagation", style: "cursor: help;", data: { toggle: "popover", trigger: "focus", html: true, content: t(translation_key), title: t("common.help") } do
      tag.i class: "fa fa-question-circle ml-3"
    end
  end

  def js_flash
    flash.map do |type, message|
      toastr_method = MESSAGE_TYPE_MAP[type] || type
      message.blank? ? "" : "toastr.#{toastr_method}('#{message}');".html_safe
    end.join("\n").html_safe
  end

  def current_season_as_js_array
    [current_season.start_date.beginning_of_day.strftime(ToursReport::DATETIME_FORMAT),
     current_season.end_date.beginning_of_day.strftime(ToursReport::DATETIME_FORMAT)]
  end

  def distance_of_date_in_words_to_now(date)
    key = ""
    distance = nil
    if date == Date.current
      key = "today"
    elsif Date.tomorrow == date
      key = "tomorrow"
    else
      key = "in_x_days"
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

  def title_row(title)
    content_tag("div", class: "row bg-white pt-3") do
      content_tag("div", class: "col-sm-6") do
        capture do
          concat content_tag("h1", title)
          concat(yield) if block_given?
        end
      end
    end
  end

  def empty_message(locale_key, postfix = "")
    content_tag("div", class: "row mt-5") do
      content_tag("div", class: "col-6 m-auto text-center") do
        concat content_tag("h3", t("views.#{locale_key}.empty_info_title" + postfix))
        concat content_tag("p", t("views.#{locale_key}.empty_info" + postfix), class: "lead")
      end
    end
  end

  def reasonability_warnings(reasonability)
    reasonability.warnings.map{ |key|
      I18n.t(key)
    }.join('<br>').html_safe
  end

  def toolbar_row
    content_tag("div", class: "row toolbar border-top bg-light p-2 d-print-none") do
      yield if block_given?
    end
  end

  def content_card(opts = {})
    body = opts.delete(:body)
    card_css = opts.delete(:card_css)
    content_tag("div", class: "row mt-3") do
      content_tag("div", class: "col-12") do
        content_tag("div", class: "card #{card_css}") do
          if body
            content_tag("div", class: "card-body") do
              yield if block_given?
            end
          else
            yield if block_given?
          end
        end
      end
    end
  end

end

