# :stopdoc:
require File.dirname(__FILE__) + '/../../test_helper'
require_or_load 'admin/events_controller'

# Re-raise errors caught by the controller.
class Admin::EventsController; def rescue_action(e) raise e end; end

class Admin::EventsControllerTest < Test::Unit::TestCase

  include ApplicationHelper

  def setup
    @controller = Admin::EventsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_show
    @request.session[:user] = users(:candi)
    banana_belt = events(:banana_belt_1)
    opts = {:controller => "admin/events", :action => "show", :id => banana_belt.to_param.to_s}
    assert_routing("/admin/events/#{banana_belt.to_param}", opts)
    
    # expose old bug
    race = banana_belt.standings.first.races.first
    race.result_columns = race.result_columns_or_default
    race.result_columns << 'hometown'
    race.save(false)
    
    get(:show, :id => banana_belt.to_param.to_s)
    assert_response(:success)
    assert_template("admin/events/show")
    assert_not_nil(assigns["event"], "Should assign event")
    assert_nil(assigns["race"], "Should not assign race")
  end

  def test_show_parent
    @request.session[:user] = users(:candi)
    banana_belt = events(:banana_belt_series)
    opts = {:controller => "admin/events", :action => "show", :id => banana_belt.to_param.to_s}
    assert_routing("/admin/events/#{banana_belt.to_param}", opts)
    
    get(:show, :id => banana_belt.to_param.to_s)
    assert_response(:success)
    assert_template("admin/events/show")
    assert_not_nil(assigns["event"], "Should assign event")
    assert_nil(assigns["race"], "Should not assign race")
  end

  def test_show_no_results
    @request.session[:user] = users(:candi)
    mt_hood_1 = events(:mt_hood_1)
    opts = {:controller => "admin/events", :action => "show", :id => mt_hood_1.to_param.to_s}
    assert_routing("/admin/events/#{mt_hood_1.to_param}", opts)
    get(:show, :id => mt_hood_1.to_param.to_s)
    assert_response(:success)
    assert_template("admin/events/show")
    assert_not_nil(assigns["event"], "Should assign event")
    assert_nil(assigns["race"], "Should not assign race")
  end

  def test_show_with_standings
    @request.session[:user] = users(:candi)
    kings_valley = events(:kings_valley)
    standings = kings_valley.standings.first
    opts = {:controller => "admin/events", :action => "show", :id => kings_valley.to_param.to_s, :standings_id => standings.to_param.to_s,}
    assert_routing("/admin/events/#{kings_valley.to_param}/#{standings.to_param}", opts)
    get(:show, :id => kings_valley.to_param, :standings_id => standings.to_param)
    assert_response(:success)
    assert_template("admin/events/show")
    assert_not_nil(assigns["event"], "Should assign event")
    assert_nil(assigns["race"], "Should not assign race")
  end

  def test_show_with_race
    @request.session[:user] = users(:candi)
    kings_valley = events(:kings_valley)
    standings = kings_valley.standings.first
    kings_valley_3 = races(:kings_valley_3)
    opts = {:controller => "admin/events", :action => "show", :id => kings_valley.to_param.to_s, :standings_id => standings.to_param.to_s, :race_id => kings_valley_3.to_param.to_s}
    assert_routing("/admin/events/#{kings_valley.to_param}/#{standings.to_param}/#{kings_valley_3.to_param}", opts)
    get(:show, :id => kings_valley.to_param, :standings_id => standings.to_param, :race_id => kings_valley_3.to_param)
    assert_response(:success)
    assert_template("admin/events/show")
    assert_not_nil(assigns["event"], "Should assign event")
    assert_equal(kings_valley_3, assigns["race"], "Should assign kings_valley_3 race")
  end

  def test_show_with_promoter
    @request.session[:user] = users(:candi)
    banana_belt = events(:banana_belt_1)
    opts = {:controller => "admin/events", :action => "show", :id => banana_belt.to_param.to_s, :promoter_id => '2'}
    assert_recognizes(opts, "/admin/events/#{banana_belt.to_param}", :promoter_id => '2')
    
    # expose old bug
    race = banana_belt.standings.first.races.first
    race.result_columns = race.result_columns_or_default
    race.result_columns << 'hometown'
    race.save(false)
    
    assert_not_equal(promoters(:candi_murray), banana_belt.promoter, 'Promoter before show with promoter ID')

    get(:show, :id => banana_belt.to_param.to_s)
    assert_response(:success)
    assert_template("admin/events/show")
    assert_not_nil(assigns["event"], "Should assign event")
    assert_nil(assigns["race"], "Should not assign race")
    assert_not_equal(promoters(:candi_murray), assigns["event"].promoter, 'Promoter from promoter ID')
  end

  def test_upload
    @request.session[:user] = users(:candi)
    mt_hood_1 = events(:mt_hood_1)
    assert(mt_hood_1.standings.empty?, 'Should have no standings before import')
    
    file = uploaded_file("/test/fixtures/results/pir_2006_format.xls", "pir_2006_format.xls", "application/vnd.ms-excel")
    opts = {
      :controller => "admin/events", 
      :action => "upload",
      :id => mt_hood_1.to_param.to_s
    }
    assert_routing("/admin/events/upload/#{mt_hood_1.to_param}", opts)

    post :upload, :id => mt_hood_1.to_param, :results_file => file

    assert(!flash.has_key?(:warn), "flash[:warn] should be empty,  but was: #{flash[:warn]}")
    assert_response :redirect
    assert_redirected_to(:action => :show, :id => mt_hood_1.to_param, :standings_id => mt_hood_1.standings(true).last.to_param)
    assert(flash.has_key?(:notice))
    assert(!mt_hood_1.standings(true).empty?, 'Should have standings after upload attempt')
  end

  def test_upload_invalid_columns
    @request.session[:user] = users(:candi)
    mt_hood_1 = events(:mt_hood_1)
    assert(mt_hood_1.standings.empty?, 'Should have no standings before import')
    
    file = uploaded_file("/test/fixtures/results/invalid_columns.xls", "invalid_columns.xls", "application/vnd.ms-excel")
    post :upload, :id => mt_hood_1.to_param, :results_file => file
    assert_redirected_to(:action => :show, :id => mt_hood_1.to_param, :standings_id => mt_hood_1.standings(true).last.to_param)

    assert_response :redirect
    assert(flash.has_key?(:notice))
    assert(flash.has_key?(:warn))
    assert(!mt_hood_1.standings(true).empty?, 'Should have standings after upload attempt')
  end
  
  def test_new_single_day_event
    @request.session[:user] = users(:candi)
    opts = {:controller => "admin/events", :action => "new", :year => '2008'}
    assert_routing("/admin/events/new/2008", opts)
    get(:new, :year => '2008')
    assert_response(:success)
    assert_template('admin/events/new')
    assert_not_nil(assigns["event"], "Should assign event")
  end

  def test_new_single_day_event_default_year
    @request.session[:user] = users(:candi)
    opts = {:controller => "admin/events", :action => "new"}
    assert_generates("/admin/events/new", opts)
    get(:new)
    assert_response(:success)
    assert_template('admin/events/new')
    assert_not_nil(assigns["event"], "Should assign event")
    assert_equal(Date.today.year, assigns["event"].date.year)
  end
  
  def test_create_event
    @request.session[:user] = users(:candi)

    opts = {:controller => "admin/events", :action => "create"}
    assert_routing("/admin/events/create", opts)

    assert_nil(Event.find_by_name('Skull Hollow Roubaix'), 'Skull Hollow Roubaix should not be in DB')

    post(:create, 
         "commit"=>"Save", 
         "event"=>{"city"=>"Smith Rock", "name"=>"Skull Hollow Roubaix","date"=>"2010-01-02",
                   "flyer"=>"http://timplummer.org/roubaix.html", "sanctioned_by"=>"WSBA", "flyer_approved"=>"1", 
                   "discipline"=>"Downhill", "cancelled"=>"1", "state"=>"KY",
                  'promoter_id' => '3'}
    )
    
    skull_hollow = Event.find_by_name('Skull Hollow Roubaix')
    assert_not_nil(skull_hollow, 'Skull Hollow Roubaix should be in DB')
    
    assert_response(:redirect)
    assert_redirected_to(:action => :show, :id => skull_hollow.to_param)

    assert_equal('Skull Hollow Roubaix', skull_hollow.name, 'name')
    assert_equal('Smith Rock', skull_hollow.city, 'city')
    assert_equal(Date.new(2010, 1, 2), skull_hollow.date, 'date')
    assert_equal('http://timplummer.org/roubaix.html', skull_hollow.flyer, 'flyer')
    assert_equal('WSBA', skull_hollow.sanctioned_by, 'sanctioned_by')
    assert_equal(true, skull_hollow.flyer_approved, 'flyer_approved')
    assert_equal('Downhill', skull_hollow.discipline, 'discipline')
    assert_equal(true, skull_hollow.cancelled, 'cancelled')
    assert_equal('KY', skull_hollow.state, 'state')
    assert_equal(promoters(:nate_hobson), skull_hollow.promoter, 'promoter')
  end
  
  def test_upload_dupe_racers
    # Two racers with different name, same numbers
    # Excel file has Greg Rodgers with no number
    Racer.create(:name => 'Greg Rodgers', :road_number => '404')
    Racer.create(:name => 'Greg Rodgers', :road_number => '500')
    
    @request.session[:user] = users(:candi)
    mt_hood_1 = events(:mt_hood_1)
    assert(mt_hood_1.standings(true).empty?, 'Should have no standings before import')
    
    file = uploaded_file("/test/fixtures/results/dupe_racers.xls", "dupe_racers.xls", "application/vnd.ms-excel")
    post :upload, :id => mt_hood_1.to_param, :results_file => file
    
    assert_response :redirect
    
    # Dupe racers used to be allowed, and this would have been an error
    assert(!mt_hood_1.standings(true).empty?, 'Should have standings after importing dupe racers')
    assert(!flash.has_key?(:warn))
  end

  def test_destroy_race
    @request.session[:user] = users(:candi)
    kings_valley_women_2003 = races(:kings_valley_women_2003)
    opts = {:controller => "admin/events", :action => "destroy_race", :id => kings_valley_women_2003.to_param.to_s}
    assert_routing("/admin/events/destroy_race/#{kings_valley_women_2003.to_param}", opts)
    post(:destroy_race, :id => kings_valley_women_2003.id, :commit => 'Delete')
    assert_response(:success)
    assert_raise(ActiveRecord::RecordNotFound, 'kings_valley_women_2003 should have been destroyed') { Race.find(kings_valley_women_2003.id) }
  end

  def test_destroy_standings
    @request.session[:user] = users(:candi)
    jack_frost = standings(:jack_frost)
    opts = {:controller => "admin/events", :action => "destroy_standings", :id => jack_frost.to_param.to_s}
    assert_routing("/admin/events/destroy_standings/#{jack_frost.to_param}", opts)
    post(:destroy_standings, :id => jack_frost.id, :commit => 'Delete')
    assert_response(:success)
    assert_raise(ActiveRecord::RecordNotFound, 'jack_frost should have been destroyed') { Standings.find(jack_frost.id) }
  end

  def test_destroy_result
    @request.session[:user] = users(:candi)
    tonkin_kings_valley = results(:tonkin_kings_valley)
    opts = {:controller => "admin/events", :action => "destroy_result", :id => tonkin_kings_valley.to_param.to_s}
    assert_routing("/admin/events/destroy_result/#{tonkin_kings_valley.to_param}", opts)
    post(:destroy_result, :id => tonkin_kings_valley.id, :commit => 'Delete')
    assert_response(:success)
    assert_raise(ActiveRecord::RecordNotFound, 'tonkin_kings_valley should have been destroyed') { Result.find(tonkin_kings_valley.id) }
  end

  def test_update_event
    @request.session[:user] = users(:candi)
    banana_belt = events(:banana_belt_1)
    opts = {:controller => "admin/events", :action => "update", :id => banana_belt.to_param.to_s}
    assert_routing("/admin/events/update/#{banana_belt.to_param}", opts)

    assert_not_equal('Banana Belt One', banana_belt.name, 'name')
    assert_not_equal('Forest Grove', banana_belt.city, 'city')
    assert_not_equal('Geoff Mitchem', banana_belt.promoter_name, 'promoter_name')
    assert_not_equal(Date.new(2006, 03, 12), banana_belt.date, 'date')
    assert_not_equal('../../flyers/2006/banana_belt.html', banana_belt.flyer, 'flyer')
    assert_not_equal('UCI', banana_belt.sanctioned_by, 'sanctioned_by')
    assert_not_equal(true, banana_belt.flyer_approved, 'flyer_approved')
    assert_not_equal('503-233-3636', banana_belt.promoter_phone, 'promoter_phone')
    assert_not_equal('JMitchem@ffadesign.com', banana_belt.promoter_email, 'promoter_email')
    assert_not_equal('Track', banana_belt.discipline, 'discipline')
    assert_not_equal(true, banana_belt.cancelled, 'cancelled')
    assert_not_equal('OR', banana_belt.state, 'state')

    post(:update, 
         "commit"=>"Save", 
         :id => banana_belt.to_param.to_s,
         "event"=>{"city"=>"Forest Grove", "name"=>"Banana Belt One","date"=>"2006-03-12",
                   "flyer"=>"../../flyers/2006/banana_belt.html", "sanctioned_by"=>"UCI", "flyer_approved"=>"1", 
                   "discipline"=>"Track", "cancelled"=>"1", "state"=>"OR",
                  'promoter_id' => '1'}
    )
    assert_response(:redirect)
    assert_redirected_to(:action => :show, :id => banana_belt.to_param.to_s)

    banana_belt.reload
    assert_equal('Banana Belt One', banana_belt.name, 'name')
    assert_equal('Forest Grove', banana_belt.city, 'city')
    assert_equal(Date.new(2006, 03, 12), banana_belt.date, 'date')
    assert_equal('../../flyers/2006/banana_belt.html', banana_belt.flyer, 'flyer')
    assert_equal('UCI', banana_belt.sanctioned_by, 'sanctioned_by')
    assert_equal(true, banana_belt.flyer_approved, 'flyer_approved')
    assert_equal('Track', banana_belt.discipline, 'discipline')
    assert_equal(true, banana_belt.cancelled, 'cancelled')
    assert_equal('OR', banana_belt.state, 'state')
    assert_equal('Brad Ross', banana_belt.promoter_name, 'promoter_name')
    assert_nil(banana_belt.promoter_phone, 'promoter_phone')
    assert_nil(banana_belt.promoter_email, 'promoter_email')
  end

  def test_update_standings
    @request.session[:user] = users(:candi)
    banana_belt = standings(:banana_belt)
    opts = {:controller => "admin/events", :action => "update", :id => banana_belt.event.to_param.to_s, :standings_id => banana_belt.to_param.to_s}
    assert_routing("/admin/events/update/#{banana_belt.event.to_param}/#{banana_belt.to_param}", opts)

    assert_not_equal('Banana Belt One', banana_belt.name, 'name')
    assert_not_equal(2, banana_belt.bar_points, 'bar_points')
    assert_not_equal('Cyclocross', banana_belt.discipline, 'discipline')

    post(:update, 
         "commit"=>"Save", 
         :id => banana_belt.event.to_param.to_s,
         :standings_id => banana_belt.to_param.to_s,
         "standings"=>{"bar_points"=>"2", "name"=>"Banana Belt One", "discipline"=>"Cyclocross"}
    )
    assert_response(:redirect)
    assert_redirected_to(:action => :show, :id => banana_belt.event.to_param.to_s, :standings_id => banana_belt.to_param.to_s)

    banana_belt.reload
    assert_equal('Banana Belt One', banana_belt.name, 'name')
    assert_equal('Cyclocross', banana_belt.discipline, 'discipline')
    assert_equal(2, banana_belt.bar_points, 'bar_points')
  end

  def test_update_discipline_nil
    @request.session[:user] = users(:candi)
    banana_belt = standings(:banana_belt)
    banana_belt.update_attribute(:discipline, nil)
    assert_nil(banana_belt[:discipline], 'discipline')
    assert_equal('Road', banana_belt.event.discipline, 'Parent event discipline')

    post(:update, 
         "commit"=>"Save", 
         :id => banana_belt.event.to_param.to_s,
         :standings_id => banana_belt.to_param.to_s,
         "standings"=>{"bar_points"=>"2", "name"=>"Banana Belt One", "discipline"=>"Road"}
    )
    assert_response(:redirect)
    assert_redirected_to(:action => :show, :id => banana_belt.event.to_param.to_s, :standings_id => banana_belt.to_param.to_s)

    banana_belt.reload
    assert_nil(banana_belt[:discipline], 'discipline')
  end

  def test_update_discipline_same_as_parent
    @request.session[:user] = users(:candi)
    banana_belt = standings(:banana_belt)
    assert_equal('Road', banana_belt[:discipline], 'discipline')
    assert_equal('Road', banana_belt.event.discipline, 'Parent event discipline')

    post(:update, 
         "commit"=>"Save", 
         :id => banana_belt.event.to_param.to_s,
         :standings_id => banana_belt.to_param.to_s,
         "standings"=>{"bar_points"=>"2", "name"=>"Banana Belt One", "discipline"=>"Road"}
    )
    assert_response(:redirect)
    assert_redirected_to(:action => :show, :id => banana_belt.event.to_param.to_s, :standings_id => banana_belt.to_param.to_s)

    banana_belt.reload
    assert_nil(banana_belt[:discipline], 'discipline')
  end

  def test_update_error
    @request.session[:user] = users(:candi)
    banana_belt = events(:banana_belt_1)
    opts = {:controller => "admin/events", :action => "update", :id => banana_belt.to_param.to_s}
    assert_routing("/admin/events/update/#{banana_belt.to_param}", opts)

    assert_equal('Banana Belt I', banana_belt.name, 'name')

    post(:update, 
         "commit"=>"Save", 
         :id => banana_belt.to_param.to_s,
         "event"=>{"city"=>"Forest Grove", "name"=>"", "promoter_d"=>"", "date"=>"99822sasa!",
                   "flyer"=>"../../flyers/2006/banana_belt.html", "sanctioned_by"=>ASSOCIATION.short_name, "flyer_approved"=>"1",
                  "discipline"=>"Road", "cancelled"=>"1", "state"=>"OR"}
    )
    assert_response(:success)
    assert_template("admin/events/show")
    assert_not_nil(assigns['event'], 'Should assign event')
    assert_not_nil(flash[:warn], "Should have warning after invalid update")
    banana_belt.reload
    assert_equal('Banana Belt I', banana_belt.name, 'name')
  end
  
  def test_update_bar_points
    @request.session[:user] = users(:candi)
    race = races(:banana_belt_pro_1_2)

    opts = {:controller => "admin/events", :action => "update_bar_points", :id => race.to_param.to_s}
    assert_routing("/admin/events/update_bar_points/#{race.to_param}", opts)

    assert_equal(nil, race[:bar_points], ':bar_points')
    assert_equal(1, race.bar_points, 'BAR points')

    post(:update_bar_points, 
         :id => race.to_param.to_s,
         :bar_points => '2'
    )
    assert_response(:success)

    race.reload
    assert_equal(2, race[:bar_points], ':bar_points')
    assert_equal(2, race.bar_points, 'BAR points')
  end

  def test_save_no_promoter
    assert_nil(SingleDayEvent.find_by_name('Silverton'), 'Silverton should not be in database')
    # New event, no changes, single day, no promoter
    @request.session[:user] = users(:candi)
    post(:create, 
         "commit"=>"Save", 
         'same_promoter' => 'true',
         "event"=>{"name"=>"Silverton",
                  'promoter_id' => ""}
    )
    assert_response(:redirect)
    silverton = SingleDayEvent.find_by_name('Silverton')
    assert_not_nil(silverton, 'Silverton should be in database')
    assert(!silverton.new_record?, "Silverton should be saved")
    assert_nil(silverton.promoter, "Silverton Promoter")
    assert_redirected_to(:action => :show, :id => silverton.to_param)
  end
  
  def test_save_different_promoter
    @request.session[:user] = users(:candi)
    banana_belt = events(:banana_belt_1)
    assert_equal(promoters(:brad_ross), banana_belt.promoter, 'Promoter before save')
    
    post(:update, 
         "commit"=>"Save", 
         :id => banana_belt.to_param.to_s,
         "event"=>{"city"=>"Forest Grove", "name"=>"Banana Belt One","date"=>"2006-03-12",
                   "flyer"=>"../../flyers/2006/banana_belt.html", "sanctioned_by"=>"UCI", "flyer_approved"=>"1", 
                   "discipline"=>"Track", "cancelled"=>"1", "state"=>"OR",
                  'promoter_id' => '3'}
    )
    assert_nil(flash[:warn], 'flash[:warn]')
    assert_response(:redirect)
    assert_redirected_to(:action => :show, :id => banana_belt.to_param.to_s)
    
    banana_belt.reload
    assert_equal(promoters(:nate_hobson), banana_belt.promoter(true), 'Promoter after save')
  end
  
  def test_delete
    tabor_cr = events(:tabor_cr)

    @request.session[:user] = users(:candi)
    post(:update,
         'id' => tabor_cr.to_param,
         "commit"=>"Delete", 
         'same_promoter' => 'false',
         "event"=>{"city"=>"Smith Rock", "name"=>"Skull Hollow Roubaix","date"=>"2010-01-02",
                   "flyer"=>"http://timplummer.org/roubaix.html", "sanctioned_by"=>"WSBA", "flyer_approved"=>"1", 
                   "discipline"=>"Downhill", "cancelled"=>"1", "state"=>"KY",
                  'promoter' => {"name"=>"Tim Plummer",  "phone"=>"503-913-7676", "email"=>"tplummer@gmail.com"}}
    )
    assert_response(:redirect)
    
    assert(!Event.exists?(tabor_cr.id), "Tabor should be deleted")
  end

  def test_upcoming_events
    @request.session[:user] = users(:candi)
    opts = {:controller => "admin/events", :action => "upcoming"}
    assert_routing("/admin/events/upcoming", opts)
    get(:upcoming)
    assert_response(:success)
    assert_template("admin/events/upcoming")
  end
  
  def test_upcoming_events_refresh
    @request.session[:user] = users(:candi)
    post(:upcoming, "commit"=>"Refresh", "date"=>{"month"=>"6", "day"=>"25", "year"=>"2004"}, "weeks"=>"6")
    assert_response(:success)
    assert_template("admin/events/upcoming")
  end

  private

  def uploaded_file(path, original_filename, content_type)
    file_contents = File.new("#{RAILS_ROOT}/#{path}").read
    uploaded_file = StringIO.new(file_contents);
    (class << uploaded_file; self; end).class_eval do
      alias local_path path
      define_method(:original_filename) {original_filename}
      define_method(:content_type) {content_type}
    end
    return uploaded_file
  end
end