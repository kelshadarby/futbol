require_relative 'game_statistics'
require_relative 'league_statistics'
require_relative 'season_statistics'
require_relative 'game_team'
require_relative 'game'
require_relative 'team'

class StatTracker

  def self.from_csv(locations)
    game_path = locations[:games]
    team_path = locations[:teams]
    game_teams_path = locations[:game_teams]
    StatTracker.new(game_path, team_path, game_teams_path)
  end

  attr_reader :games, :teams, :game_teams
  def initialize(game_path, team_path, game_teams_path)
    @games = Game.create_games(game_path)
    @teams = Team.create_teams(team_path)
    @game_teams = GameTeam.create_game_teams(game_teams_path)
    @game_statistic = GameStatistics.new
    @league_statistic = LeagueStatistics.new
    @season_statistic = SeasonStatistics.new
  end

  def highest_total_score; @game_statistic.highest_total_score; end

  def lowest_total_score; @game_statistic.lowest_total_score; end

  def biggest_blowout; @game_statistic.biggest_blowout; end

  def count_of_games_by_season; @game_statistic.count_of_games_by_season; end

  def average_goals_per_game; @game_statistic.average_goals_per_game; end

  def average_goals_by_season; @game_statistic.average_goals_by_season; end

  def percentage_home_wins; @game_statistic.percentage_home_wins; end

  def percentage_visitor_wins; @game_statistic.percentage_visitor_wins; end

  def percentage_ties; @game_statistic.percentage_ties; end

  def most_accurate_team(season_id); @season_statistic.most_accurate_team(season_id); end

  def least_accurate_team(season_id); @season_statistic.least_accurate_team(season_id); end

  def winningest_coach(season_id);@season_statistic.winningest_coach(season_id); end

  def worst_coach(season_id);@season_statistic.worst_coach(season_id); end

  def biggest_bust; @season_statistic.biggest_bust; end

  def biggest_surprise; @season_statistic.biggest_surprise; end

  def most_tackles(season_id); @season_statistic.most_tackles(season_id); end

  def fewest_tackles(season_id); @season_statistic.fewest_tackles(season_id); end

end
