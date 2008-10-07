require File.dirname(__FILE__) + '/../../test_helper'

module TableHelper
  class ColumnTest < ActiveSupport::TestCase
    def test_new
      table = Table.new(:racers)
      column = TableHelper::Column.new(table, :name)
      assert_equal("Name", column.title, "title")
      assert_equal(:name, column.attribute, "attribute")
      assert_equal("name", column.style_class, "style_class")
      assert_equal(false, column.link, "link")
      assert_equal(false, column.editable?, "editable")
      assert_equal(nil, column.format, "format")
      assert_equal(table, column.table, "table")
      assert_equal([:name], column.order, "order")
    end

    def test_options
      table = Table.new(:racers)
      column = TableHelper::Column.new(table, :team, :title => "Equipe", :style_class => "team_name", :format => "%a %m/%d", :link => true, 
                                       :editable => true, :order => [:last_name, :first_name])
      assert_equal("Equipe", column.title, "title")
      assert_equal("team_name", column.style_class, "style_class")
      assert_equal(:team, column.attribute, "attribute")
      assert_equal(true, column.link?, "link")
      assert_equal(true, column.editable?, "editable")
      assert_equal("%a %m/%d", column.format, "format")
      assert_equal(table, column.table, "table")
      assert_equal([:last_name, :first_name], column.order, "order")
    end
    
    def test_table_ordered_by_different_attribute
      table = Table.new(:racers, nil, nil, "team_name desc")
      column = TableHelper::Column.new(table, :name)
      assert_equal("name asc", column.order_param, "order_param")
    end
    
    def test_table_ordered_by_same_attribute_asc
      table = Table.new(:racers, nil, nil, "name asc")
      column = TableHelper::Column.new(table, :name)
      assert_equal("name desc", column.order_param, "order_param")
    end
    
    def test_table_ordered_by_same_attribute_desc
      table = Table.new(:racers, nil, nil, "name desc")
      column = TableHelper::Column.new(table, :name)
      assert_equal("name asc", column.order_param, "order_param")
    end
    
    def test_table_ordered_by_many_different_attribute
      table = Table.new(:racers, nil, nil, "first_name asc, last_name asc")
      column = TableHelper::Column.new(table, :name)
      assert_equal("name asc", column.order_param, "order_param")
    end
    
    def test_table_ordered_by_many_same_attribute_asc
      table = Table.new(:racers, nil, nil, "first_name asc, last_name asc")
      column = TableHelper::Column.new(table, [:first_name, :last_name])
      assert_equal("first_name desc, last_name desc", column.order_param, "order_param")
    end
    
    def test_table_ordered_by_many_same_attribute_desc
      table = Table.new(:racers, nil, nil, "first_name desc, last_name desc")
      column = TableHelper::Column.new(table, [:first_name, :last_name])
      assert_equal("first_name asc, last_name asc", column.order_param, "order_param")
    end
    
    def test_table_ordered_by_many_many_same_attribute_desc
      table = Table.new(:racers, nil, nil, "first_name desc, last_name desc, team_name desc, age desc")
      column = TableHelper::Column.new(table, [:first_name, :last_name, :team_name, :age])
      assert_equal("first_name asc, last_name asc, team_name asc, age asc", column.order_param, "order_param")
    end
  end
end