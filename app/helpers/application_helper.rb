# Methods added to this helper will be available to all templates in the application.
# Application-wide Racing on Rails helper code is in RacingOnRailsControllerHelper
module ApplicationHelper
  def focus(form_field_name)
    render("shared/focus", :object => form_field_name)
  end

  # Wrap +text+ in div tags, unless +text+ is blank
  def div(text)
    "<div>#{text}</div>" unless text.blank?
  end
  
  def page_title
    return "#{ASSOCIATION.short_name}: #{@page_title}" if @page_title
    
    if @page && !@page.title.blank?
      return "#{ASSOCIATION.short_name}: #{@page.title}"
    end
    
    "#{ASSOCIATION.short_name}: #{controller.controller_name.titleize}: #{controller.action_name.titleize}"
  end
  
  # Defaults to text length of 20
  def truncate_from_end(text)
    return text if text.blank? || text.size <= 20
    
    "...#{text[-20, 20]}"
  end

  # Only need this helper once, it will provide an interface to convert a block into a partial.
  # 1. Capture is a Rails helper which will 'capture' the output of a block into a variable
  # 2. Merge the 'body' variable into our options hash
  # 3. Render the partial with the given options hash. Just like calling the partial directly.
  def block_to_partial(partial_name, options = {}, &block)
    options.merge!(:body => capture(&block))
    concat(render(:partial => partial_name, :locals => options))
  end
end
