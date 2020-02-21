require_relative 'test_helper'
require './lib/stat_tracker'
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
    # add another assert
  end

  def test_finding_away_games_for_a_team
    assert_equal 4, @stat_tracker.away_games(6).length
  end

  def test_getting_home_win_percentage_for_a_team
    skip
    assert_equal 15, @stat_tracker.home_win_percentage(6)
  end

  def test_getting_away_win_percentage_for_a_team
    skip
    assert_equal 40, @stat_tracker.away_win_percentage(6)
  end

  def test_getting_the_team_with_the_best_fans
    skip
    assert_equal 6, @stat_tracker.best_fans(6)
  end

  # Name of the team with biggest difference between
  # home and away win percentages.

  def test_getting_the_teams_with_the_worst_fans
    skip
  end

  # List of names of all teams with better away records than home records.



end
