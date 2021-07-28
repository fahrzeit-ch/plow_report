# frozen_string_literal: true

Trestle.resource(:companies) do
  helper ApplicationHelper
  helper SeasonSelection
  menu do
    item :companies, icon: "fa fa-star"
  end

  # Customize the tabFAH-le columns shown on the index view.
  #
  table autolink: true do
    column :name
    column :contact_email
    column :city
    column :created_at, align: :center
    actions do |toolbar, instance, admin|
      toolbar.show if admin && admin.actions.include?(:edit)
      toolbar.edit if admin && admin.actions.include?(:edit)
      toolbar.delete if admin && admin.actions.include?(:destroy)
    end
  end

  # Customize the form fields shown on the new/edit views.
  #
  form do |company|
    text_field :name
    text_field :contact_email
    text_field :address
    text_field :zip_code
    text_field :city
  end

  controller do
    def show
      @company = Company.find(params[:id])
      base_price = Rails.configuration.billing['usage_base_price']
      discount_per_day = Rails.configuration.billing['usage_discount_per_day']
      @season = params[:season].blank? ? Season.new : Season.from_sym(params[:season])
      @usage_cost = Billing::UsageCosts.new base_price, discount_per_day, @company.id, @season
    end
  end

  routes do
    get :show, on: :member
  end

  # By default, all parameters passed to the update and create actions will be
  # permitted. If you do not have full trust in your users, you should explicitly
  # define the list of permitted parameters.
  #
  # For further information, see the Rails documentation on Strong Parameters:
  #   http://guides.rubyonrails.org/action_controller_overview.html#strong-parameters
  #
  # params do |params|
  #   params.require(:company).permit(:name, ...)
  # end
end
