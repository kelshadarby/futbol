require_relative 'test_helper'
require 'mocha/minitest'
require './lib/stat_tracker'
require './lib/stat_tracker'
require './lib/game'
require './lib/team'
require './lib/game_team'
require './lib/game_statistics'
require './lib/league_statistics'
require './lib/season_statistics'
require './lib/statistics'

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
    @statistics = Statistics.new
  end

  def test_it_exists
    assert_instance_of StatTracker, @stat_tracker
  end

  def test_it_can_create_objects
    assert_instance_of Game, @stat_tracker.games[2]
    assert_instance_of Team, @stat_tracker.teams[2]
    assert_instance_of GameTeam, @stat_tracker.game_teams[2]
  end

  def test_it_can_calculate_highest_total_score
    assert_equal 7, @stat_tracker.highest_total_score
  end

  def test_it_can_calculate_lowest_total_score
    assert_equal 1, @stat_tracker.lowest_total_score
  end

  def test_it_can_find_biggest_blowout
    assert_equal 4, @stat_tracker.biggest_blowout
  end

  def test_it_can_calculate_count_of_games_by_season
    assert_equal ({"20122013"=>51, "20132014"=>29}), @stat_tracker.count_of_games_by_season
  end

  def test_it_can_average_goals_per_game
    assert_equal 4.01, @stat_tracker.average_goals_per_game
  end

  def test_it_can_average_goals_by_season
    assert_equal ({"20122013"=>4.02, "20132014"=>4.0}), @stat_tracker.average_goals_by_season
  end

  def test_it_can_find_percentage_home_wins
    assert_equal 0.68, @stat_tracker.percentage_home_wins
  end

  def test_it_can_find_percentage_visitor_wins
    assert_equal 0.25, @stat_tracker.percentage_visitor_wins
  end

  def test_it_can_find_percentage_ties
    assert_equal 0.05, @stat_tracker.percentage_ties
  end

  def test_it_can_count_teams
    assert_equal 32, @stat_tracker.count_of_teams
  end

  def test_it_can_tell_best_offense
    assert_equal "FC Dallas", @stat_tracker.best_offense
  end

  def test_it_can_tell_worst_offense
    assert_equal "Sporting Kansas City", @stat_tracker.worst_offense
  end

  def test_it_can_tell_best_defense
    assert_equal "Orlando Pride", @stat_tracker.best_defense
  end

  def test_it_can_tell_worst_defense
    assert_equal "New York Red Bulls", @stat_tracker.worst_defense
  end

  def test_it_can_tell_highest_scoring_visitor
    assert_equal "Orlando Pride", @stat_tracker.highest_scoring_visitor
  end

  def test_lowest_scoring_visitor
    assert_equal "DC United", @stat_tracker.lowest_scoring_visitor
  end

  def test_highest_scoring_home_team
    assert_equal "New York City FC", @stat_tracker.highest_scoring_home_team
  end

  def test_it_can_tell_lowest_scoring_home_team
    assert_equal "DC United", @stat_tracker.lowest_scoring_home_team
  end

  def test_it_can_tell_winningest_team
    assert_equal "FC Dallas", @stat_tracker.winningest_team
  end

  def test_getting_the_team_with_the_best_fans
    assert_equal "New York City FC", @stat_tracker.best_fans
  end

  def test_getting_the_teams_with_the_worst_fans
    @statistics.stubs(:away_win_percentage).returns(80)
    expected = ["Houston Dynamo", "Sporting Kansas City", "New England Revolution", "New York Red Bulls"]
    assert_equal expected, @stat_tracker.worst_fans
  end

  def test_most_accurate_team
     assert_equal "New York City FC", @stat_tracker.most_accurate_team(20122013)
  end

  def test_can_get_least_accurate_team
    assert_equal "Sporting Kansas City", @stat_tracker.least_accurate_team(20122013)
  end

  def test_winningest_coach
    assert_equal "Claude Julien", @stat_tracker.winningest_coach(20122013)
  end

  def test_worst_coach
    assert_equal "John Tortorella", @stat_tracker.worst_coach(20122013)
  end

  def test_it_can_tell_biggest_bust
    @statistics.stubs(:percent_wins_regular_season).returns({3=>0.66, 4=>0.75})
    @statistics.stubs(:percent_wins_postseason).returns({3=>0.33, 4=>0.25})

    assert_equal "Chicago Fire", @stat_tracker.biggest_bust
  end

  def test_it_can_tell_biggest_surprise
    @statistics.stubs(:percent_wins_regular_season).returns({3=>0.66, 4=>0.75})
    @statistics.stubs(:percent_wins_postseason).returns({3=>0.33, 4=>0.25})

    assert_equal "Houston Dynamo", @stat_tracker.biggest_surprise
  end

  def test_most_tackles
    assert_equal "FC Dallas", @stat_tracker.most_tackles(20122013)
  end

  def test_fewest_tackles
    assert_equal "New York City FC", @stat_tracker.fewest_tackles(20122013)
  end
end
