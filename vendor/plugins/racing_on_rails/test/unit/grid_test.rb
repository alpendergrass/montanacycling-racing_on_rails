require File.dirname(__FILE__) + '/../test_helper'

class GridTest < Test::Unit::TestCase

  def test_new
    Grid.new
    Grid.new(nil)
  end
  
  def test_new_empty_text
    text = ""
    grid = Grid.new(text, [])
    assert_equal(0, grid.column_count, "column count")
    assert_equal(0, grid.row_count, "row count")
    assert_equal(0, grid.column_size(0), "column 0 size")
    assert_equal(0, grid.column_size(90), "column 90 size")
    assert_equal("", grid.to_s, "to_s")
  end
  
  def test_new_one_line_text
    text = "1\t001\tChris Horner\tSaunier\t9"
    grid = Grid.new(text, [])
    assert_equal(5, grid.column_count, "column count")
    assert_equal(1, grid.row_count, "row count")
    assert_equal(1, grid.column_size(0), "column 0 size")
    assert_equal(12, grid.column_size(2), "column 2 size")
    assert_equal("1", grid[0][0], "grid[0][0]")
    assert_equal("9", grid[0][4], "grid[0][4]")
    assert_equal("", grid[0][18], "grid[0][18]")
    assert_equal("1   001   Chris Horner   Saunier   9\n", grid.to_s, "to_s")
  end
  
  def test_new_many_lines
    text = <<END
      Place \tNumber\tLast Name\tFirst Name\tTeam\tCategory Raced
      1\t189\tWillson\tScott\tGentle Lover\tSenior Men 1/2/3\t11\t\t11
      2\t190\tPhinney\tHarry\tCCCP\tSenior Men 1/2/3\t9\t\t
      3\t10a\tHolland\tSteve\tHuntair\tSenior Men 1/2/3\t\t3\t
      dnf\t100\tBourcier\tPaul\tHutch's\tSenior Men 1/2/3\t\t\t1
END
    grid = Grid.new(text, [])
    assert_equal(9, grid.column_count, "column count")
    assert_equal(5, grid.row_count, "row count")
    assert_equal(6, grid.column_size(1), "column 1 size")
    assert_equal(9, grid.column_size(2), "column 2 size")
    assert_equal("1", grid[1][0], "grid[1][0]")
    assert_equal("CCCP", grid[2][4], "grid[2][4]")
    assert_equal("", grid[3][18], "grid[3][18]")
    expected_text = <<END
Place   Number   Last Name   First Name   Team           Category Raced                
1       189      Willson     Scott        Gentle Lover   Senior Men 1/2/3   11       11
2       190      Phinney     Harry        CCCP           Senior Men 1/2/3   9          
3       10a      Holland     Steve        Huntair        Senior Men 1/2/3        3     
dnf     100      Bourcier    Paul         Hutch's        Senior Men 1/2/3            1 
END
    assert_equal(expected_text, grid.to_s, "to_s")
  end
  
  def test_new_array
    text = [
      "Place \tNumber\tLast Name\tFirst Name\tTeam\tCategory Raced\n",
      "1\t189\tWillson\tScott\tGentle Lover\tSenior Men 1/2/3\t11\t\t11\n",
      "2\t190\tPhinney\tHarry\tCCCP\tSenior Men 1/2/3\t9\t\t\n",
      "3\t10a\tHolland\tSteve\tHuntair\tSenior Men 1/2/3\t\t3\t\n",
      "dnf\t100\tBourcier\tPaul\tHutch's\tSenior Men 1/2/3\t\t\t1\n"
    ]
    grid = Grid.new(text, [])
    assert_equal(9, grid.column_count, "column count")
    assert_equal(5, grid.row_count, "row count")
    assert_equal(6, grid.column_size(1), "column 1 size")
    assert_equal(9, grid.column_size(2), "column 2 size")
    assert_equal("1", grid[1][0], "grid[1][0]")
    assert_equal("CCCP", grid[2][4], "grid[2][4]")
    assert_equal("", grid[3][18], "grid[3][18]")
  end
  
  def test_set_value
    columns = ["place", "number", "racer.last_name", "racer.first_name", "team.name", "racer.category"]
    text = <<END
      1\t189\tWillson\tScott\tGentle Lover\tSenior Men 1/2/3\t11\t\t11
      2\t190\tPhinney\tHarry\tCCCP\tSenior Men 1/2/3\t9\t\t
      3\t10a\tHolland\tSteve\tHuntair\tSenior Men 1/2/3\t\t3\t
      dnf\t100\tBourcier\tPaul\tHutch's\tSenior Men 1/2/3\t\t\t1
END
    grid = Grid.new(text, columns)
    assert_equal("CCCP", grid[1][4], "grid[1][4]")
    grid[1][4] = "Gentle Lovers"
    assert_equal("Gentle Lovers", grid[1][4], "grid[1][4]")
    grid[1][4] = nil
    assert_equal("", grid[1][4], "grid[1][4]")
  end
  
  def test_columns
    columns = ["Place", "Number", "Last Name", "First Name", "Team", "Category Raced"]
    text = <<END
      1\t189\tWillson\tScott\tGentle Lover\tSenior Men 1/2/3\t11\t\t11
      2\t190\tPhinney\tHarry\tCCCP\tSenior Men 1/2/3\t9\t\t
      3\t10a\tHolland\tSteve\tHuntair\tSenior Men 1/2/3\t\t3\t
      dnf\t100\tBourcier\tPaul\tHutch's\tSenior Men 1/2/3\t\t\t1
END
    grid = Grid.new(text, columns)
    assert_equal("Huntair", grid[2][4], "grid[2][4]")
    assert_equal("Huntair", grid[2]["Team"], "grid[2][""Team""]")
    assert_equal("", grid[2]["Weight"], "grid[2][""Weight""]")
    assert_equal(:"Last Name", grid.columns[2].field, "third column field")
    assert_equal("Last Name", grid.columns[2].name, "third column name")
  end

  def test_empty_to_s_text
    text = ""
    columns = [
      Column.new('place', '', 3, true, Column::RIGHT),
      Column.new('number', 'Number', 5, true),
      Column.new('last_name', 'Last Name', 15, true)
    ]
    grid = Grid.new(text, columns)
    assert_equal(3, grid.column_count, "column count")
    assert_equal(0, grid.row_count, "row count")
    assert_equal(5, grid.column_size(1), "column 1 size")
    assert_equal(0, grid.column_size(90), "column 90 size")
    assert_equal("      Nu...   Last Name      \n", grid.to_s, "to_s")
    assert_equal("", grid.to_s(false), "to_s")
  end

    def test_column_formatting
      text = <<END
        1\t189\tWillson\tScott\tGentle Lover\tSenior Men 1/2/3\t11\t\t11
        2\t190\tPhinney-Carpenter\tHarry\tCCCP\tSenior Men 1/2/3\t9\t\t
        3\t10a\tHolland\tSteve\tHuntair\tSenior Men 1/2/3\t\t3\t
        dnf\t100\tBourcier\tPaul\tHutch's\tSenior Men 1/2/3\t\t\t1
END
      columns = [
        Column.new('place', '', 3, true, Column::RIGHT),
        Column.new('number', 'Number', 5),
        Column.new('last_name', 'Last Name', 15, true),
        Column.new('first_name', 'First Name', 12),
        Column.new('team_name', 'Team', 30),
        Column.new('category', 'Category', 20),
        Column.new('points', '', 3, true, Column::RIGHT),
        Column.new('points_bonus_penalty', '', 3, true, Column::RIGHT),
        Column.new('points_total', '', 3, true, Column::RIGHT)
      ]
      grid = Grid.new(text, columns)
      assert_equal(9, grid.column_count, "column count")
      assert_equal(4, grid.row_count, "row count")
      assert_equal(6, grid.column_size(1), "column 1 size")
      assert_equal(15, grid.column_size(2), "column 2 size")
      assert_equal("1", grid[0][0], "grid[0][0]")
      assert_equal("CCCP", grid[1][4], "grid[1][4]")
      assert_equal("", grid[2][18], "grid[2][18]")
      expected_text = <<END
      Number   Last Name         First Name     Team                             Category                              
  1   189      Willson           Scott          Gentle Lover                     Senior Men 1/2/3        11          11
  2   190      Phinney-Carp...   Harry          CCCP                             Senior Men 1/2/3         9            
  3   10a      Holland           Steve          Huntair                          Senior Men 1/2/3               3      
dnf   100      Bourcier          Paul           Hutch's                          Senior Men 1/2/3                     1
END
      assert_equal(expected_text, grid.to_s, "to_s")
    end
    
    def test_delete_blank_rows
      columns = ["Place", "Number", "Last Name", "First Name", "Team", "Category Raced", "points"]
      text = <<END
        1\t189\tWillson\tScott\tGentle Lover\tSenior Men 1/2/3\t11\t\t11
        2\t190\tPhinney-Carpenter\tHarry\tCCCP\tSenior Men 1/2/3\t9\t\t
        \t\t\t\t\t\t\t\t 
        3\t10a\tHolland\tSteve\tHuntair\tSenior Men 1/2/3\t\t3\t
        dnf\t100\tBourcier\tPaul\tHutch's\tSenior Men 1/2/3\t\t\t1
        \t\t\t  \t\t\t\t\t
        \t\t\t\t\t\t\t\t
END
      grid = Grid.new(text, columns)
      assert_equal(7, grid.row_count, "row count")
      grid.delete_blank_rows
      assert_equal(4, grid.row_count, "row count")
    end
end