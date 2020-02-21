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




end
