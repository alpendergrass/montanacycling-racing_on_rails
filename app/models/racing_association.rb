# TODO Should this be in database as full-fledged ActiveRecord?
# bar_point_schedule should be stored in the database with the BAR?
class RacingAssociation

  attr_accessor :name, :short_name, :state, :email
  attr_accessor :masters_age
  attr_accessor :gender_specific_numbers, :rental_numbers, :bmx_numbers, :default_discipline
  attr_accessor :competitions
  attr_accessor :award_cat4_participation_points, :cat4_womens_race_series_points, :cat4_womens_race_series_category
  attr_accessor :show_license, :show_only_association_sanctioned_races_on_calendar, :show_calendar_view, :flyers_in_new_window
  attr_accessor :always_insert_table_headers
  attr_accessor :show_events_velodrome, :show_events_sponsoring_team
  attr_accessor :usac_region
  attr_accessor :default_sanctioned_by
  attr_accessor :usac_results_format
  
  def initialize
    @masters_age = 35
    @show_license = true
    @show_events_velodrome = true
    @show_events_sponsoring_team = false  #mbrahere
    @show_only_association_sanctioned_races_on_calendar = true
    @email = "scott@butlerpress.com"
    @competitions = Set.new([:age_graded_bar, :bar, :ironman, :overall_bar, :team_bar])
    @award_cat4_participation_points = true
    @usac_region = "North West"
    @usac_results_format = false  #mbrahere
  end
  
  def bmx_numbers?
    @bmx_numbers
  end
  
  def default_discipline
    @default_discipline ||= "Road"
#mbrahere: I had:
#    @default_discipline ||= "road"

  end
  
  def default_sanctioned_by
    @default_sanctioned_by || short_name
  end

  def gender_specific_numbers?
    @gender_specific_numbers
  end
  
  def flyers_in_new_window?
    @flyers_in_new_window
  end
  
  def always_insert_table_headers?
    @always_insert_table_headers
  end
  
  def show_calendar_view?
    @show_calendar_view
  end
  
  def show_events_velodrome?
    @show_events_velodrome
  end

  def show_events_sponsoring_team?
    @show_events_sponsoring_team
  end
  
  def award_cat4_participation_points?
    @award_cat4_participation_points
  end

  def usac_results_format?
    @usac_results_format
  end

  def to_s
    "#<RacingAssociation #{short_name} #{name}>"
  end
end
