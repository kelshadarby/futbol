require_relative 'test_helper'
require './lib/stat_tracker'

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

  def test_attributes
    assert_equal './test/fixtures/games_truncated.csv', @stat_tracker.game_path
    assert_equal './test/fixtures/teams_truncated.csv', @stat_tracker.team_path
    assert_equal './test/fixtures/game_teams_truncated.csv', @stat_tracker.game_teams_path
  end
end
