# Allows to autofill in forms based on types
# of the given attributes
class FormFiller
  include Capybara::DSL

  def initialize(base_name, values)
    @base_name = base_name
    @values = values
  end

  def auto_fill
    @values.each do |k, v|
      try_fill(k, infer_method_from_type(v))
    end
  end

  def infer_method_from_type(val)
    case val
      when Time
        :fill_in_time
      when DateTime
        :fill_in_time
      when TrueClass
        :check
      when FalseClass
        :check
      else
        :fill_in
    end
  end

  def try_fill(key, method=:fill_in)
    if method == :check
      try_check key
    elsif method == :fill_in_time
      fill_in_time(key)
    else
      send(method, field_name(key), with: @values[key])
    end
  end

  def try_check(key)
    check field_name(key) if @values[key]
  end

  def fill_in_time(key)
    fill_in field_name(key), with: @values[key].strftime('%H:%M')
  end

  def field_name(key)
    "#{@base_name}[#{key}]"
  end
end

module SystemScenarios

  # Sign in a user by visiting sign in form and fill in
  # email address and password
  def sign_in_with(email, password)
    visit '/users/sign_in'
    fill_form 'user', { email: email, password: password }
    click_button I18n.t('devise.sign_in')
  end

  # Sign up a new user
  def sign_up(attrs)
    visit '/users/sign_in'
    fill_form'user', attrs.slice(:email, :password, :password_confirmation)
    click_button I18n.t('devise.sign_up')
  end

  # Start recording a new drive (expects be signed in and have no active recording)
  def start_recording_drive
    visit '/'
    yield if block_given?
    click_link_or_button I18n.t('dashboard.cards.new_drive.start_recording')
  end

  def finish_recording_drive
    visit '/'
    yield if block_given?
    click_link_or_button I18n.t('dashboard.cards.new_drive.finish_recording')
  end

  def fill_form(name, values)
    filler = FormFiller.new name, values
    filler.auto_fill
  end

  # FIll in a drive form with valid values
  # options:
  #   * except: array of attributes that should not be filled
  #   * only: array with keys, only fill in given keys
  #   * attributes: overwrite the defaults
  def fill_drive_form(options={})
    opts = { attributes: {}, except: [], only: [] }.merge options

    values = attributes_for(:drive, opts[:attributes]) # default values from factory

    # apply except or only keys
    values.except!(options[:except]) unless options[:except].blank?
    values.slice!(options[:only]) unless options[:only].blank?

    fill_form 'drive', values
  end


end

