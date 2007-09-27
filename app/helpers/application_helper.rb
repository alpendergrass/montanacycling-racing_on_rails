# Methods added to this helper will be available to all templates in the application.
# Application-wide Racing on Rails helper code is in RacingOnRailsControllerHelper
module ApplicationHelper
  @@grid_columns = nil
  
  # Class-scope Hash of Columns, keyed by field
  # Used to display results in a grid
  # TODO Rewrite this a bit smarter
  def grid_columns(column)
    if @@grid_columns.nil?
      @@grid_columns = Hash.new
      @@grid_columns['age'] = Column.new(:name => 'age', :description => 'Age', :size => 3, :fixed_size => true)
      @@grid_columns['category_name'] = Column.new(:name => 'category_name', :description => 'Category', :size => 20, :fixed_size => true)
      @@grid_columns['city'] = Column.new(:name => 'city', :description => 'City', :size => 15, :fixed_size => true)
      @@grid_columns['date_of_birth'] = Column.new(:name => 'date_of_birth', :description => 'Date of Birth', :size => 15)
      @@grid_columns['first_name'] = Column.new(:name => 'first_name', :description => 'First Name', :size => 12, :fixed_size => true)
      @@grid_columns['first_name'].link = 'link_to(cell, "#{APP_SERVER_ROOT}/results/racer/#{result.racer.id}") if result.racer'
      @@grid_columns['last_name'] = Column.new(:name => 'last_name', :description => 'Last Name', :size => 18, :fixed_size => true)
      @@grid_columns['last_name'].link = 'link_to(cell, "#{APP_SERVER_ROOT}/results/racer/#{result.racer.id}") if result.racer'
      @@grid_columns['license'] = Column.new(:name => 'license', :description => 'Lic', :size => 7)
      @@grid_columns['name'] = Column.new(:name => 'name', :description => 'Name', :size => 30, :fixed_size => true)
      @@grid_columns['name'].link = 'link_to(cell, "#{APP_SERVER_ROOT}/results/racer/#{result.racer.id}") if result.racer'
      @@grid_columns['notes'] = Column.new(:name => 'notes', :description => 'Notes', :size => 12)
      @@grid_columns['number'] = Column.new(:name => 'number', :description => 'Num', :size => 4, :fixed_size => true)
      @@grid_columns['number'].link = 'link_to(cell, "#{APP_SERVER_ROOT}/results/racer/#{result.racer.id}") if result.racer'
      @@grid_columns['place'] = Column.new(:name => 'place', :description => 'Pl', :size => 3, :fixed_size => true, :justification => Column::RIGHT)
      @@grid_columns['points'] = Column.new(:name => 'points', :description => 'Points', :size => 6, :fixed_size => true, :justification => Column::RIGHT)
      @@grid_columns['points_from_place'] = Column.new(:name => 'points_from_place', :description => 'Finish Pts', :size => 10, :fixed_size => true, :justification => Column::RIGHT)
      @@grid_columns['points_total'] = Column.new(:name => 'points_total', :description => 'Total Pts', :size => 10, :fixed_size => true, :justification => Column::RIGHT)
      @@grid_columns['state'] = Column.new(:name => 'state', :description => 'ST', :size => 3)
      @@grid_columns['team_name'] = Column.new(:name => 'team_name', :description => 'Team', :size => 40)
      @@grid_columns['time'] = Column.new(:name => 'time', :description => 'Time', :size => 8, :justification => Column::RIGHT)
      @@grid_columns['time'].field = :time_s
      @@grid_columns['time_bonus_penalty'] = Column.new(:name => 'time_bonus_penalty', :description => 'Bon/Pen', :size => 7, :justification => Column::RIGHT)
      @@grid_columns['time_bonus_penalty'].field = :time_bonus_penalty_s
      @@grid_columns['time_gap_to_leader'] = Column.new(:name => 'time_gap_to_leader', :description => 'Down', :size => 6, :justification => Column::RIGHT)
      @@grid_columns['time_gap_to_leader'].field = :time_gap_to_leader_s
      @@grid_columns['time_total'] = Column.new(:name => 'time_total', :description => 'Overall', :size => 8, :justification => Column::RIGHT)
      @@grid_columns['time_total'].field = :time_total_s
    end
    grid_column = @@grid_columns[column]
    if grid_column.nil?
      grid_column = Column.new(:name => column)
      @@grid_columns[column] = grid_column
    end
    grid_column
  end

  # Should field from model object displayed by a RecordEditor
  # TODO: Move to Admin::RecordEditor?
  def attribute(record, name)
    render(:partial => '/admin/attribute', :locals => {:record => record, :name => name})
  end
  
  def tabs
    tabs = Tabs.new(@controller)
    yield tabs
    tabs.to_html
  end
  
  def image(name)
    return '' if name.blank?
    
    img = Image.find_by_name(name)
    return '' unless img

    if img.link
      eval("link_to(image_tag(img.source #{', ' + img.html_options unless img.html_options.blank? }), #{img.link}, {:class => 'image'})")
    else
      image_tag(img.source)
    end
  end
  
  def caption(name)
    return '' if name.blank?
    
    img = Image.find_by_name(name)
    return '' unless img

    if img.caption.blank?
      ''
    else
      eval(img.caption)
    end
  end
end

class Tabs
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper
  
  def initialize(controller)
    @controller = controller
    @tabs = []
  end
  
  def add(name, options = {}, html_options = nil, *parameters_for_method_reference)
    _html_options = {:onmouseover => "hover(this)", :onmouseout => "hoverOut(this)"}
    _html_options.merge(html_options) if html_options
    @tabs << [name, options, _html_options, parameters_for_method_reference]
  end
  
  def select(name)
    @selected_name = name
  end
  
  # Builder escapes text, which is not what we want
  def to_html
    table_class = "tabs"
    table_class = "tabs_solo" if @tabs.size < 2
    html = <<HTML
<div style="text-align: center;">
  <table class="#{table_class}">
    <tr>
HTML
    @tabs.each_with_index do |tab, index|
      if index == 0
        if current_page?(tab[1])
          html << "      <td class=\"first_selected\"><div class=\"first_selected\">"
        else
          html << "      <td class=\"first\"><div class=\"first\">"
        end
        html << link_to_unless_current(tab.first, tab[1], tab[2], tab[3]).to_s
        html << "</div>"
        if @tabs.size < 2
          if current_page?(tab[1])
            html << "</td>\n      <td class=\"last_selected\"><div class=\"last_selected\"></div>"
          else
            html << "</td>\n      <td class=\"last\"><div class=\"last\"></div>"
          end
        end
      elsif index == @tabs.size - 1
        if current_page?(tab[1])
          html << "      <td class=\"last_selected\"><div class=\"last_selected\">"
        else
          html << "      <td class=\"last\"><div class=\"last\">"
        end
        html << link_to_unless_current(tab.first, tab[1], tab[2], tab[3]).to_s
        html << "</div>"
      else
        if current_page?(tab[1])
          html << "      <td class=\"selected\"><div class=\"selected\">"
        else
          html << "      <td><div>"
        end
        html << link_to_unless_current(tab.first, tab[1], tab[2], tab[3]).to_s
        html << "</div>"
      end
      html << "</td>\n"
    end
    end_html = <<HTML
    </tr>
  </table>
</div>
HTML
    html << end_html
  end
end
