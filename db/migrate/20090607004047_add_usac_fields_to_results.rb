class AddUsacFieldsToResults < ActiveRecord::Migration
  def self.up
    if ASSOCIATION.short_name == "MBRA"
      rename_column :results, :ages, :age_group
    else
      add_column :results, :gender, :string, :limit => 8
      add_column :results, :category_class, :string, :limit => 16
      add_column :results, :age_group, :string, :limit => 16
    end
  end

  def self.down
    if ASSOCIATION.short_name == "MBRA"
      rename_column :results, :age_group, :ages
    else
      remove_column :results, :gender
      remove_column :results, :category_class
      remove_column :results, :age_group
    end
  end
end
