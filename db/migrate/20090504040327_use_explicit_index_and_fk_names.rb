class UseExplicitIndexAndFkNames < ActiveRecord::Migration
  def self.up
    # Sadly, schemas are not totally congruent, so be fault-tolerant with rescue nil
    execute "alter table aliases drop foreign key aliases_ibfk_1" rescue nil
    execute "alter table aliases drop foreign key aliases_ibfk_2" rescue nil
    execute "alter table categories drop foreign key categories_ibfk_3" rescue nil
    execute "alter table competition_event_memberships drop foreign key competition_event_memberships_ibfk_1"
    execute "alter table competition_event_memberships drop foreign key competition_event_memberships_ibfk_2"
    execute "alter table discipline_aliases drop foreign key discipline_aliases_ibfk_1" rescue nil
    execute "alter table discipline_bar_categories drop foreign key discipline_bar_categories_ibfk_1" rescue nil
    execute "alter table discipline_bar_categories drop foreign key discipline_bar_categories_ibfk_2" rescue nil
    execute "alter table duplicates_racers drop foreign key duplicates_racers_ibfk_1" rescue nil
    execute "alter table duplicates_racers drop foreign key duplicates_racers_ibfk_2" rescue nil
    execute "alter table events drop foreign key events_ibfk_1" rescue nil
    execute "alter table events drop foreign key events_ibfk_2" rescue nil
    execute "alter table events drop foreign key events_ibfk_3" rescue nil
    execute "alter table events drop foreign key events_ibfk_4" rescue nil
    execute "alter table events drop foreign key events_ibfk_5" rescue nil
    execute "alter table events drop foreign key events_ibfk_6" rescue nil
    execute "alter table events drop foreign key events_ibfk_7" rescue nil
    execute "alter table events drop foreign key events_ibfk_8" rescue nil
    execute "alter table historical_names drop foreign key historical_names_ibfk_1" rescue nil
    execute "alter table pages drop foreign key pages_ibfk_1" rescue nil
    execute "alter table posts drop foreign key posts_ibfk_1" rescue nil
    execute "alter table race_numbers drop foreign key race_numbers_ibfk_1" rescue nil
    execute "alter table race_numbers drop foreign key race_numbers_ibfk_2" rescue nil
    execute "alter table race_numbers drop foreign key race_numbers_ibfk_3" rescue nil
    execute "alter table racers drop foreign key racers_ibfk_1" rescue nil
    execute "alter table races drop foreign key races_ibfk_1" rescue nil
    execute "alter table races drop foreign key races_ibfk_2" rescue nil
    execute "alter table results drop foreign key results_ibfk_1" rescue nil
    execute "alter table results drop foreign key results_ibfk_3" rescue nil
    execute "alter table results drop foreign key results_ibfk_4" rescue nil
    execute "alter table results drop foreign key results_ibfk_5" rescue nil
    execute "alter table roles_users drop foreign key roles_users_ibfk_1" rescue nil
    execute "alter table roles_users drop foreign key roles_users_ibfk_2" rescue nil
    execute "alter table scores drop foreign key scores_ibfk_1" rescue nil
    execute "alter table scores drop foreign key scores_ibfk_2" rescue nil

    execute "alter table aliases add constraint aliases_racer_id_fk foreign key (racer_id) references racers (id) on delete cascade" rescue nil
    execute "alter table aliases add constraint aliases_team_id_fk foreign key (team_id) references teams (id) on delete cascade" rescue nil
    execute "alter table categories add constraint categories_categories_id_fk foreign key (parent_id) references categories (id) on delete cascade" rescue nil
    execute "alter table competition_event_memberships add constraint competition_event_memberships_competitions_id_fk foreign key (competition_id) references events (id) on delete cascade" rescue nil
    execute "alter table competition_event_memberships add constraint competition_event_memberships_events_id_fk foreign key (event_id) references events (id) on delete cascade" rescue nil
    execute "alter table discipline_aliases add constraint discipline_aliases_disciplines_id_fk foreign key (discipline_id) references disciplines (id) on delete cascade" rescue nil
    execute "alter table discipline_bar_categories add constraint discipline_bar_categories_categories_id_fk foreign key (category_id) references categories (id) on delete cascade" rescue nil
    execute "alter table discipline_bar_categories add constraint discipline_bar_categories_disciplines_id_fk foreign key (discipline_id) references disciplines (id) on delete cascade" rescue nil
    execute "alter table duplicates_racers add constraint duplicates_racers_racers_id_fk foreign key (racer_id) references racers (id) on delete cascade" rescue nil
    execute "alter table duplicates_racers add constraint duplicates_racers_duplicates_id_fk foreign key (duplicate_id) references duplicates (id) on delete cascade" rescue nil
    execute "alter table events add constraint events_events_id_fk foreign key (parent_id) references events (id) on delete cascade" rescue nil
    execute "alter table events add constraint events_promoters_id_fk foreign key (promoter_id) references promoters (id) on delete set null" rescue nil
    execute "alter table events add constraint events_oregon_cup_id_fk foreign key (oregon_cup_id) references events (id) on delete set null" rescue nil
    execute "alter table events add constraint events_number_issuers_id_fk foreign key (number_issuer_id) references number_issuers (id)" rescue nil
    execute "alter table events add constraint events_velodrome_id_fk foreign key (velodrome_id) references velodromes (id)" rescue nil
    execute "alter table events add constraint events_source_event_id_fk foreign key (source_event_id) references events (id)" rescue nil
    execute "alter table historical_names add constraint historical_names_team_id_fk foreign key (team_id) references teams (id)" rescue nil
    execute "alter table pages add constraint pages_parent_id_fk foreign key (parent_id) references pages (id)" rescue nil
    execute "alter table posts add constraint posts_mailing_list_id_fk foreign key (mailing_list_id) references mailing_lists (id)" rescue nil
    execute "alter table race_numbers add constraint race_numbers_racer_id_fk foreign key (racer_id) references racers (id) on delete cascade" rescue nil
    execute "alter table race_numbers add constraint race_numbers_discipline_id_fk foreign key (discipline_id) references disciplines (id)" rescue nil
    execute "alter table race_numbers add constraint race_numbers_number_issuer_id_fk foreign key (number_issuer_id) references number_issuers (id)" rescue nil
    execute "alter table racers add constraint racers_team_id_fk foreign key (team_id) references teams (id)" rescue nil
    execute "alter table races add constraint races_category_id_fk foreign key (category_id) references categories (id)" rescue nil
    execute "alter table races add constraint races_event_id_fk foreign key (event_id) references events (id) on delete cascade" rescue nil
    execute "alter table results add constraint results_category_id_fk foreign key (category_id) references categories (id)" rescue nil
    execute "alter table results add constraint results_race_id_fk foreign key (race_id) references races (id) on delete cascade" rescue nil
    execute "alter table results add constraint results_racer_id_fk foreign key (racer_id) references racers (id)" rescue nil
    execute "alter table results add constraint results_team_id_fk foreign key (team_id) references teams (id)" rescue nil
    execute "alter table roles_users add constraint roles_users_role_id_fk foreign key (role_id) references roles (id) on delete cascade" rescue nil
    execute "alter table roles_users add constraint roles_users_user_id_fk foreign key (user_id) references users (id) on delete cascade" rescue nil
    execute "alter table scores add constraint scores_competition_result_id_fk foreign key (competition_result_id) references results (id) on delete cascade" rescue nil
    execute "alter table scores add constraint scores_source_result_id_fk foreign key (source_result_id) references results (id) on delete cascade" rescue nil
  end
end
