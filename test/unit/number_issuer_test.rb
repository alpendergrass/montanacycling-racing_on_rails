require "test_helper"

class NumberIssuerTest < ActiveSupport::TestCase

  def test_create
    NumberIssuer.create(:name => 'Elkhorn Classic SR')
    assert(!NumberIssuer.new.valid?, 'Null name')
    assert(!NumberIssuer.new(:name => '').valid?, 'Empty name')
  end
end