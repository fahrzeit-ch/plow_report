module ApplicationHelper

  def current_path(params_overwrite)
    p = params.clone
    p.merge!(params_overwrite)
    p.permit!
    url_for(p)
  end

end
