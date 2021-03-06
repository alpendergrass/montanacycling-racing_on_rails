class OregonCupController < ApplicationController
  def index
    @year = params['year'] || Date.today.year.to_s
    date = Date.new(@year.to_i, 1, 1)
    @oregon_cup = OregonCup.find(:first, :conditions => ['date = ?', date]) || OregonCup.new(:date => date)
  end
end
