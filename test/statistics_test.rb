require_relative 'test_helper'
require 'mocha/minitest'
require './lib/stat_tracker'
require './lib/game'
require './lib/team'
require './lib/game_team'
require './lib/stat_tracker'

class StatisticsTest < Minitest::Test

  def setup
    game_path = './test/fixtures/games_truncated.csv'
    team_path = './test/fixtures/teams_truncated.csv'
    game_teams_path = './test/fixtures/game_teams_truncated.csv'

    locations = {
      games: game_path,
      teams: team_path,
      game_teams: game_teams_path
    }
    @stat_tracker = StatTracker.from_csv(locations)
    @statistics = Statistics.new
  end

  def test_it_exists
    assert_kind_of Statistics, @statistics
  end

  def test_it_can_create_objects
    assert_instance_of Game, @statistics.games[2]
    assert_instance_of Team, @statistics.teams[2]
    assert_instance_of GameTeam, @statistics.game_teams[2]
  end

  def test_it_can_find_all_seasons
    assert_equal [20122013, 20132014], @statistics.find_all_seasons
  end

  def test_it_can_find_team_names
    assert_equal "FC Dallas", @statistics.find_team_names(6)
  end

  def test_it_can_calculate_goals_per_team
    expected = {
      3=>[2, 2, 1, 2, 1],
      6=>[3, 3, 2, 3, 3, 3, 4, 2, 1],
      5=>[0, 1, 1, 0],
      17=>[1, 2, 3, 2, 1, 3, 1],
      16=>[2, 1, 1, 0, 2, 2, 2],
      9=>[2, 1, 4],
      8=>[2, 3, 1, 2]
    }
    assert_equal expected, @statistics.goals_per_team
  end

  def test_it_can_average_goals_per_team
    expected = {
      3=>1.6,
      6=>2.67,
      5=>0.5,
      17=>1.86,
      16=>1.43,
      9=>2.33,
      8=>2.0
    }
    assert_equal expected, @statistics.average_goals_per_team
  end

  def test_it_can_tell_games_teams_and_allowed_goals
    assert_equal [3, 3, 2, 3, 3], @statistics.games_teams_and_allowed_goals[3]
  end

  def test_it_can_average_games_teams_and_allowed_goals
    assert_equal 2.8, @statistics.average_games_teams_and_allowed_goals[3]
  end

  def test_it_can_tell_visiting_teams_and_goals
    assert_equal [2, 3, 3, 4, 3], @statistics.visiting_teams_and_goals[6]
  end

  def test_it_can_tell_average_visiting_teams_and_goals
    assert_equal 3, @statistics.average_visiting_teams_and_goals[6]
  end

  def test_it_can_return_home_teams_and_goals
    assert_equal [3, 3, 3, 2, 1, 2, 2, 4, 2], @statistics.home_teams_and_goals[6]
  end

  def test_it_can_calculate_average_home_teams_and_goals
    assert_equal 2.44, @statistics.average_home_teams_and_goals[6]
  end

  def test_it_can_create_game_team_results
    assert_equal ["TIE", "WIN", "LOSS", "LOSS"], @statistics.game_team_results[8]
  end

  def test_it_can_calculate_percent_wins
    assert_equal 0.25, @statistics.percent_wins[8]
  end

  def test_finding_home_games_for_a_team
    assert_equal 5, @statistics.home_games(6).length
    assert_equal @statistics.game_teams[1], @statistics.home_games(6)[0]
  end

  def test_finding_away_games_for_a_team
    assert_equal 4, @statistics.away_games(6).length
    assert_includes @statistics.away_games(6), @statistics.game_teams[4]
  end

  def test_getting_home_win_percentage_for_a_team
    assert_equal 75.0, @statistics.home_win_percentage(16)
    assert_equal 100, @statistics.home_win_percentage(9)
  end

  def test_getting_away_win_percentage_for_a_team
    assert_equal 25.0, @statistics.away_win_percentage(17)
    assert_equal 100.0, @statistics.away_win_percentage(6)
  end

  def test_all_teams_playing
    assert_equal [3, 6, 5, 17, 16, 9, 8], @statistics.all_teams_playing
  end

  def test_it_can_get_game_teams_that_season
      assert_kind_of Array, @statistics.game_teams_that_season(8, 20122013)
      assert_equal 4, @statistics.game_teams_that_season(8, 20122013).length
  end

  def test_all_goals_that_season
    expected = 0.22857
    assert_equal expected, @statistics.goals_to_shots_ratio_that_season(8, 20122013)
  end

  def test_if_can_get_all_coaches
    expected = ["John Tortorella", "Claude Julien", "Dan Bylsma",
                "Mike Babcock", "Joel Quenneville", "Paul MacLean", "Michel Therrien"
                ]
    assert_equal expected, @statistics.all_coaches
  end

  def test_it_can_get_games_by_coach_and_season
    assert_kind_of Array, @statistics.game_teams_that_season_by_coach("Mike Babcock", 20122013)
    assert_equal 9, @statistics.game_teams_that_season_by_coach("Claude Julien", 20122013).length
  end

  def test_it_can_create_hash_with_coaches_and_games
    assert_kind_of Hash, @statistics.create_hash_with_team_games_by_coach(20122013)
    assert_equal 7, @statistics.create_hash_with_team_games_by_coach(20122013).length
  end

  def test_find_all_wins_by_coach
    expected = {"John Tortorella"=>0, "Claude Julien"=>9, "Dan Bylsma"=>0, "Mike Babcock"=>4, "Joel Quenneville"=>3, "Paul MacLean"=>1, "Michel Therrien"=>1}
    assert_equal expected, @statistics.finding_all_wins_by_coach(20122013)
  end

  def test_number_of_games_by_coach
    expected = {"John Tortorella"=>5, "Claude Julien"=>9, "Dan Bylsma"=>4, "Mike Babcock"=>7, "Joel Quenneville"=>7, "Paul MacLean"=>3, "Michel Therrien"=>4}
    assert_equal expected, @statistics.number_of_games_by_coach(20122013)
  end

  def test_percent_wins_by_coach
    expected = {"John Tortorella"=>0.0, "Claude Julien"=>1.0, "Dan Bylsma"=>0.0, "Mike Babcock"=>0.57, "Joel Quenneville"=>0.43, "Paul MacLean"=>0.33, "Michel Therrien"=>0.25}
    assert_equal expected, @statistics.percent_wins_by_coach(20122013)
  end

  def test_it_can_get_game_id_by_team_id_and_season_type_hash
    expected = {
      :regular=>[2012020205, 2013021119],
      :post=>[2012030121, 2012030122, 2012030123, 2012030124, 2012030125]
    }
    assert_equal expected, @statistics.game_id_by_team_id_and_season_type[9]
  end

  def test_it_can_return_post_results
    assert_equal ["TIE", "LOSS", "WIN"], @statistics.game_team_postseason_results[9]
  end

  def test_it_can_return_regular_results
    skip
    @statistics.stubs(:game_id_by_team_id_and_season_type).returns({9=>{
      :regular=>[2012020205, 2013021119],
      :post=>[2012030121, 2012030122, 2012030123, 2012030124, 2012030125]
    }})

    assert_equal ["LOSS", "WIN"], @statistics.game_team_regular_season_results[9]
  end

  def test_it_can_return_percent_postseason_wins
    assert_equal 0.33, @statistics.percent_wins_postseason[9]
  end

  def test_it_can_return_percent_regular_wins
    @statistics.stubs(:game_team_regular_season_results).returns({
      9=>["LOSS", "WIN"]
    })
    assert_equal 0.50, @statistics.percent_wins_regular_season[9]
  end
end
