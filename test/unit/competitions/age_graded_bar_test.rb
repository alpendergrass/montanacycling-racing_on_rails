require "test_helper"

class AgeGradedBarTest < ActiveSupport::TestCase  
  def test_calculate_no_results
    results_baseline_count = Result.count
    assert_equal(0, AgeGradedBar.count, "AgeGradedBar events before calculate!")
    original_results_count = Result.count
    AgeGradedBar.calculate!(2004)
    bar = AgeGradedBar.find(:first, :conditions => ['date = ?', Date.new(2004, 1, 1)])
    assert_not_nil(bar, "2004 AgeGradedBar after calculate!")
    assert_equal(1, AgeGradedBar.count, "AgeGradedBar events after calculate!")
    assert_equal(original_results_count, Result.count, "Total count of results in DB")
    # Should delete old AgeGradedBar
    AgeGradedBar.calculate!(2004)
    assert_equal(1, AgeGradedBar.count, "AgeGradedBar events after calculate!")
    bar = AgeGradedBar.find(:first, :conditions => ['date = ?', Date.new(2004, 1, 1)])
    assert_not_nil(bar, "2004 AgeGradedBar after calculate!")
    assert_equal(Date.new(2004, 1, 1), bar.date, "2004 AgeGradedBar date")
    assert_equal("2004 Age Graded BAR", bar.name, "2004 Bar name")
    assert_equal_dates(Date.today, bar.updated_at, "AgeGradedBar last updated")
    assert_equal(original_results_count, Result.count, "Total count of results in DB")    
  end
  
  def test_calculate
    # Masters 30-34 result
    weaver = people(:weaver)
    # 32
    weaver.date_of_birth = Date.new(1972)
    weaver.save!    
    banana_belt_1 = events(:banana_belt_1)
    masters_men = categories(:masters_men)
    masters_30_34 = Category.find_by_name('Masters Men 30-34')
    banana_belt_masters_30_34 = banana_belt_1.races.create!(:category => masters_30_34)
    banana_belt_masters_30_34.results.create!(:person => weaver, :place => '10')
    
    # Masters 35-39 results
    tonkin = people(:tonkin)
    # 36
    tonkin.date_of_birth = Date.new(1968)
    tonkin.save!
    masters_35_39 = Category.create!(:name => 'Masters Men 35-39', :ages => 35..39, :parent => masters_men)
    banana_belt_masters = banana_belt_1.races.create!(:category => masters_35_39)
    banana_belt_masters.results.create!(:person => tonkin, :place => '5')
    
    # Masters 35-39 result, but now is 40+ racing age
    molly = people(:molly)
    # 39 in 2004 
    molly.date_of_birth = Date.new(1965)
    molly.save!
    banana_belt_masters.results.create!(:person => molly, :place => '15')
    
    # Racing age is 35, but was 34 on race day
    carl_roberts = Person.create!(:name => 'Carl Roberts', :date_of_birth => Date.new(1969, 11, 2), :member_from => Date.new(2004), :member_to => Date.new(2004, 12, 31))
    banana_belt_masters.results.create!(:person => carl_roberts, :place => '11')
    
    # No age, but Masters result
    david_auker = Person.create!(:name => 'David Auker', :member_from => Date.new(2004), :member_to => Date.new(2004, 12, 31))
    banana_belt_masters.results.create!(:person => david_auker, :place => '9')
    
    # Result by a 32-year-old and a 36 year-old in a 30-39 race
    banana_belt_2 = events(:banana_belt_2)
    masters_30_39 = Category.create!(:name => 'Masters Men 30-39', :ages => 30..39, :parent => masters_men)
    banana_belt_2_masters_30_39 = banana_belt_2.races.create!(:category => masters_30_39)
    banana_belt_2_masters_30_39.results.create!(:person => tonkin, :place => '1')
    banana_belt_2_masters_30_39.results.create!(:person => weaver, :place => '2')    

    # Age Graded BAR is based on Overall BAR, which is based on discipline BAR
    Bar.calculate!(2004)
    OverallBar.calculate!(2004)
    
    results_baseline_count = Result.count
    assert_equal(0, AgeGradedBar.count, "AgeGradedBars before calculate!")
    original_results_count = Result.count
    AgeGradedBar.calculate!(2004)
    bar = AgeGradedBar.find(:first, :conditions => ['date = ?', Date.new(2004, 1, 1)])
    assert_not_nil(bar, "2004 AgeGradedBar after calculate!")
    assert_equal(1, AgeGradedBar.count, "AgeGradedBar events after calculate!")
    assert_equal(4, Result.count - original_results_count, "New results in DB")
    # Should delete old AgeGradedBar
    AgeGradedBar.calculate!(2004)
    assert_equal(1, AgeGradedBar.count, "AgeGradedBar events after calculate!")
    bar = AgeGradedBar.find(:first, :conditions => ['date = ?', Date.new(2004, 1, 1)])
    assert_not_nil(bar, "2004 AgeGradedBar after calculate!")
    assert_equal(Date.new(2004, 1, 1), bar.date, "2004 AgeGradedBar date")
    assert_equal("2004 Age Graded BAR", bar.name, "2004 Bar name")
    assert_equal_dates(Date.today, bar.updated_at, "AgeGradedBar last updated")
    assert_equal(original_results_count + 4, Result.count, "Total count of results in DB")
    
    assert_equal('Age Graded', bar.discipline, 'Age Graded BAR discipline')    
    
    race = bar.races.detect {|race| race.category == masters_30_34}
    assert_not_nil(race, 'Age Graded BAR should have Men 30-34 race')
    assert_equal(1, race.results.size, 'Men 30-34 should have one result')
    result = race.results.first
    assert_equal('1', result.place, 'Place')
    assert_equal(weaver, result.person, 'Person')
    assert_equal(299, result.points, 'Points')
    
    race = bar.races.detect {|race| race.category == masters_35_39}
    assert_not_nil(race, 'Age Graded BAR should have Men 35-39 race')
    assert_equal(3, race.results.size, 'Men 35-39 results')
    race.results.sort!
    result = race.results.first
    assert_equal('1', result.place, 'Place')
    assert_equal(tonkin, result.person, 'Person')
    assert_equal(300, result.points, 'Points')
    result = race.results[1]
    assert_equal('2', result.place, 'Place')
    assert_equal(carl_roberts, result.person, 'Person')
    assert_equal(297, result.points, 'Points')
    result = race.results[2]
    assert_equal('3', result.place, 'Place')
    assert_equal(molly, result.person, 'Person')
    assert_equal(296, result.points, 'Points')
  end
end