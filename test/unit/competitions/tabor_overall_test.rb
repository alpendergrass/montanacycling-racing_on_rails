require "test_helper"

class TaborOverallTest < ActiveSupport::TestCase  
  def test_recalc_with_no_tabor_series
    events_count = Event.count
    TaborOverall.calculate!
    TaborOverall.calculate!(2007)
    assert_equal(events_count, Event.count, "Should add no new Events if there are no Tabor events")
  end
  
  def test_recalc_with_one_event
    series = WeeklySeries.create!(:name => "Mt. Tabor Series")
    event = series.children.create!(:date => Date.new(2007, 6, 6))
    
    series.reload
    assert_equal(Date.new(2007, 6, 6), series.date, "Series date")
    
    cat_3_race = event.races.create!(:category => categories(:cat_3))
    cat_3_race.results.create!(:place => 1, :person => people(:weaver))
    cat_3_race.results.create!(:place => 3, :person => people(:tonkin))
    
    masters_40_plus_women_category = Category.find_or_create_by_name(:name => "Masters Women")
    masters_race = event.races.create!(:category => masters_40_plus_women_category)
    masters_race.results.create!(:place => 15, :person => people(:alice))
    masters_race.results.create!(:place => 16, :person => people(:molly))
    
    # Previous year should be ignored
    previous_event = WeeklySeries.create!(:name => "Mt. Tabor Series").children.create!(:date => Date.new(2006))
    previous_event.races.create!(:category => categories(:cat_3)).results.create!(:place => 9, :person => people(:weaver))
    
    # Following year should be ignored
    following_event = WeeklySeries.create!(:name => "Mt. Tabor Series").children.create!(:date => Date.new(2008))
    following_event.races.create!(:category => categories(:cat_3)).results.create!(:place => 10, :person => people(:weaver))
    
    TaborOverall.calculate!(2007)
    assert_not_nil(series.overall(true), "Should add new Overall to parent Series")
    assert_equal(9, series.overall.races.size, "Overall races")
    
    TaborOverall.calculate!(2007)
    assert_not_nil(series.overall(true), "Should add new overall to parent Series after deleting old overall")
    assert_equal(9, series.overall.races.size, "Overall races")
    assert_equal(1, series.overall.bar_points, "BAR points")

    cat_3_overall_race = series.overall.races.detect { |race| race.category == categories(:cat_3) }
    assert_not_nil(cat_3_overall_race, "Should have Cat 3 overall race")
    assert_equal(2, cat_3_overall_race.results.size, "Cat 3 race results")
    cat_3_overall_race.results(true).sort!
    result = cat_3_overall_race.results.first
    assert_equal("1", result.place, "Cat 3 first result place")
    assert_equal(200, result.points, "Cat 3 first result points (double points for last result)")
    assert_equal(people(:weaver), result.person, "Cat 3 first result person")
    result = cat_3_overall_race.results.last
    assert_equal("2", result.place, "Cat 3 second result place")
    assert_equal(100, result.points, "Cat 3 second result points (double points for last result)")
    assert_equal(people(:tonkin), result.person, "Cat 3 second result person")

    masters_40_plus_women_overall_race = series.overall.races.detect { |race| race.category == masters_40_plus_women_category }
    assert_not_nil(masters_40_plus_women_overall_race, "Should have Masters Women overall race")
    assert_equal(1, masters_40_plus_women_overall_race.results.size, "Masters Women race results")
    result = masters_40_plus_women_overall_race.results.first
    assert_equal("1", result.place, "Masters Women first result place")
    assert_equal(22, result.points, "Masters Women first result points  (double points for last result)")
    assert_equal(people(:alice), result.person, "Masters Women first result person")
  end
  
  def test_best_5_of_6_count
    series = WeeklySeries.create!(:name => "Mt. Tabor Series")

    event = series.children.create!(:date => Date.new(2007, 6, 6))
    event.races.create!(:category => categories(:cat_3)).results.create!(:place => 1, :person => people(:weaver))

    event = series.children.create!(:date => Date.new(2007, 6, 13))
    event.races.create!(:category => categories(:cat_3)).results.create!(:place => 14, :person => people(:weaver))

    event = series.children.create!(:date => Date.new(2007, 6, 19))
    event.races.create!(:category => categories(:cat_3)).results.create!(:place => 3, :person => people(:weaver))

    event = series.children.create!(:date => Date.new(2007, 6, 27))
    event.races.create!(:category => categories(:cat_3)).results.create!(:place => 5, :person => people(:weaver))

    event = series.children.create!(:date => Date.new(2007, 7, 4))
    event.races.create!(:category => categories(:cat_3)).results.create!(:place => 14, :person => people(:weaver))

    event = series.children.create!(:date => Date.new(2007, 7, 11))
    event.races.create!(:category => categories(:cat_3)).results.create!(:place => 11, :person => people(:weaver))
    
    TaborOverall.calculate!(2007)
    
    cat_3_overall_race = series.overall.races.detect { |race| race.category == categories(:cat_3) }
    assert_not_nil(cat_3_overall_race, "Should have Cat 3 overall race")
    assert_equal(1, cat_3_overall_race.results.size, "Cat 3 race results")
    cat_3_overall_race.results(true).sort!
    result = cat_3_overall_race.results.first
    assert_equal("1", result.place, "place")
    assert_equal(5, result.scores.size, "Scores")
    assert_equal(100 + 12 + 50 + 36 + (15 * 2), result.points, "points")
    assert_equal(people(:weaver), result.person, "person")
  end
  
  def test_double_ponts_for_final_event
    series = WeeklySeries.create!(:name => "Mt. Tabor Series")

    event = series.children.create!(:date => Date.new(2007, 6, 6))
    event.races.create!(:category => categories(:cat_3)).results.create!(:place => 1, :person => people(:weaver))

    event = series.children.create!(:date => Date.new(2007, 6, 13))
    event.races.create!(:category => categories(:cat_3)).results.create!(:place => 14, :person => people(:weaver))

    event = series.children.create!(:date => Date.new(2007, 6, 19))
    event.races.create!(:category => categories(:cat_3)).results.create!(:place => 3, :person => people(:weaver))

    event = series.children.create!(:date => Date.new(2007, 6, 27))
    event.races.create!(:category => categories(:cat_3)).results.create!(:place => 5, :person => people(:weaver))

    event = series.children.create!(:date => Date.new(2007, 7, 4))
    event.races.create!(:category => categories(:cat_3)).results.create!(:place => 13, :person => people(:weaver))

    event = series.children.create!(:date => Date.new(2007, 7, 11))
    event.races.create!(:category => categories(:cat_3)).results.create!(:place => 14, :person => people(:weaver))
    
    TaborOverall.calculate!(2007)
    
    cat_3_overall_race = series.overall.races.detect { |race| race.category == categories(:cat_3) }
    assert_not_nil(cat_3_overall_race, "Should have Cat 3 overall race")
    assert_equal(1, cat_3_overall_race.results.size, "Cat 3 race results")
    cat_3_overall_race.results(true).sort!
    result = cat_3_overall_race.results.first
    assert_equal("1", result.place, "place")
    assert_equal(5, result.scores.size, "Scores")
    assert_equal(100 + 0 + 50 + 36 + 13 + (12 * 2), result.points, "points")
    assert_equal(people(:weaver), result.person, "person")
  end
  
  def test_many_results
    series = WeeklySeries.create!(:name => "Mt. Tabor Series")
    masters = Category.find_or_create_by_name("Masters Men")
    senior_men = categories(:senior_men)
    person = Person.create!(:name => "John Browning")
    
    event = series.children.create!(:date => Date.new(2008, 6, 4))
    event.races.create!(:category => masters).results.create!(:place => 1, :person => person)
    event.races.create!(:category => senior_men).results.create!(:place => 2, :person => person)
    
    event = series.children.create!(:date => Date.new(2008, 6, 11))
    event.races.create!(:category => masters).results.create!(:place => 1, :person => person)
    event.races.create!(:category => senior_men).results.create!(:place => 2, :person => person)
    
    event = series.children.create!(:date => Date.new(2008, 6, 18))
    event.races.create!(:category => masters).results.create!(:place => 2, :person => person)
    event.races.create!(:category => senior_men).results.create!(:place => 5, :person => person)
    
    event = series.children.create!(:date => Date.new(2008, 6, 25))
    event.races.create!(:category => masters).results.create!(:place => 1, :person => person)
    event.races.create!(:category => senior_men).results.create!(:place => 2, :person => person)
    
    event = series.children.create!(:date => Date.new(2008, 7, 2))
    event.races.create!(:category => masters).results.create!(:place => 2, :person => person)
    event.races.create!(:category => senior_men).results.create!(:place => 1, :person => person)
    
    event = series.children.create!(:date => Date.new(2008, 7, 9))
    event.races.create!(:category => masters).results.create!(:place => 1, :person => person)
    event.races.create!(:category => senior_men).results.create!(:place => 20, :person => person)

    TaborOverall.calculate!(2008)
    
    masters_overall_race = series.overall.races.detect { |race| race.category == masters }
    assert_not_nil(masters_overall_race, "Should have Masters overall race")
    masters_overall_race.results(true).sort!
    result = masters_overall_race.results.first
    assert_equal("1", result.place, "place")
    assert_equal(5, result.scores.size, "Scores")
    assert_equal(100 + 100 + 70 + 100 + 0 + (100 * 2), result.points, "points")
    assert_equal(person, result.person, "person")

    senior_men_overall_race = series.overall.races.detect { |race| race.category == senior_men }
    assert_not_nil(senior_men_overall_race, "Should have Senior Men overall race")
    senior_men_overall_race.results(true).sort!
    result = senior_men_overall_race.results.first
    assert_equal("1", result.place, "place")
    assert_equal(5, result.scores.size, "Scores")
    assert_equal(70 + 70 + 36 + 70 + 100 + (0 * 2), result.points, "points")
    assert_equal(person, result.person, "person")
  end
end