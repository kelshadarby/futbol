require_relative 'test_helper'
require './lib/stat_tracker'
require 'mocha/minitest'
require './lib/game'
require './lib/team'
require './lib/game_team'

class StatTrackerTest < Minitest::Test
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
  end

  def test_it_exists
    assert_instance_of StatTracker, @stat_tracker
  end

  def test_it_can_create_objects
    assert_instance_of Game, @stat_tracker.games[2]
    assert_instance_of Team, @stat_tracker.teams[2]
    assert_instance_of GameTeam, @stat_tracker.game_teams[2]
  end



  def test_finding_home_games_for_a_team
    assert_equal 5, @stat_tracker.home_games(6).length
    assert_equal @stat_tracker.game_teams[1], @stat_tracker.home_games(6)[0]
  end

  def test_finding_away_games_for_a_team
    assert_equal 4, @stat_tracker.away_games(6).length
    assert_includes @stat_tracker.away_games(6), @stat_tracker.game_teams[4]
  end

  def test_getting_home_win_percentage_for_a_team
    assert_equal 75.0, @stat_tracker.home_win_percentage(16)
    assert_equal 100, @stat_tracker.home_win_percentage(9)
  end

  def test_getting_away_win_percentage_for_a_team
    assert_equal 33.33, @stat_tracker.away_win_percentage(17)
    assert_equal 80, @stat_tracker.away_win_percentage(6)
  end

  def test_all_teams_playing
    assert_equal [3, 6, 5, 17, 16, 9, 8], @stat_tracker.all_teams_playing
  end

  def test_changing_team_id_to_team_name
    assert_equal "Atlanta United", @stat_tracker.change_team_id_to_name(1)
    assert_equal "FC Dallas", @stat_tracker.change_team_id_to_name(6)
  end

  def test_getting_the_team_with_the_best_fans
    assert_equal "New York City FC", @stat_tracker.best_fans
  end

  def test_getting_the_teams_with_the_worst_fans
    @stat_tracker.stubs(:away_win_percentage).returns(80)
    expected = ["Houston Dynamo", "Sporting Kansas City", "New England Revolution", "New York Red Bulls"]
    assert_equal expected, @stat_tracker.worst_fans
  end


# new code, iteration 4:

  def test_can_get_gameid_of_games_that_season
    assert_kind_of Array, @stat_tracker.gameid_of_games_that_season(20122013)
    assert_equal 51, @stat_tracker.gameid_of_games_that_season(20122013).length
  end

  def test_it_can_get_game_teams_that_season
      assert_kind_of Array, @stat_tracker.game_teams_that_season(8, 20122013)
      assert_equal 4, @stat_tracker.game_teams_that_season(8, 20122013).length
  end

  def test_make_hash_with_team_games_by_team
    assert_kind_of Hash, @stat_tracker.create_hash_with_team_games_by_team(20122013)
    assert_equal 7, @stat_tracker.create_hash_with_team_games_by_team(20122013).length
    # need more testing
  end

  def test_adding_all_goals_for_each_team
    expected = {3=>8, 6=>24, 5=>2, 17=>13, 16=>10, 9=>7, 8=>8}
    assert_equal expected, @stat_tracker.teams_with_goals_total(20122013)
  end

  def test_adding_all_shots_for_each_team
    expected = {3=>38, 6=>76, 5=>32, 17=>46, 16=>58, 9=>21, 8=>35}
    assert_equal expected, @stat_tracker.teams_with_shots_total(20122013)
  end

  def test_getting_goals_to_shots_ratio
    expected = {3=>0.21, 6=>0.32, 5=>0.06, 17=>0.28, 16=>0.17, 9=>0.33, 8=>0.23}
    assert_equal expected, @stat_tracker.getting_goals_to_shots_ratio(20122013)
  end

  def test_can_get_most_accurate_team
    assert_equal "New York City FC", @stat_tracker.most_accurate_team(20122013)
    # assert_equal "New York City FC", @stat_tracker.most_accurate_team(20132014)
  end

  def test_can_get_least_accurate_team
    assert_equal "Sporting Kansas City", @stat_tracker.least_accurate_team(20122013)

  end


#   most_accurate_team	Name of the Team with the best
 # ratio of shots to goals for the season	String
# least_accurate_team	Name of the Team with the worst
 # ratio of shots to goals for the season


end
