require_relative './modules/hashable'
require_relative './modules/calculable'
require_relative 'game'
require_relative 'game_team'
require_relative 'team'

class Statistics
  include Calculable
  include Hashable
  attr_reader :games, :game_teams, :teams

  def initialize
    @games = Game.all
    @game_teams = GameTeam.all
    @teams = Team.all
  end

  def find_all_seasons
    @games.map do |game|
      game.season
    end.uniq
  end

  def find_games_by_season(season)
    @games.find_all do |game|
      game.season == season
    end
  end

  def find_team_names(team_id)
    match_team = @teams.find do |team|
      team.team_id == team_id
    end
    match_team.team_name
  end

  def goals_per_team
    @game_teams.reduce({}) do |goals_per_team, game_team|
      hash_builder(goals_per_team, game_team.team_id, game_team.goals)
    end
  end

  def average_goals_per_team
    goals_per_team.transform_values do |goals|
      average(goals.sum.to_f, goals.size)
    end
  end

  def games_teams_and_allowed_goals
    @games.reduce({}) do |teams_allowed_goals, game|
      teams_allowed_goals[game.home_team_id] = [] if teams_allowed_goals[game.home_team_id].nil?
      teams_allowed_goals[game.away_team_id] = [] if teams_allowed_goals[game.away_team_id].nil?

      teams_allowed_goals[game.home_team_id] << game.away_goals
      teams_allowed_goals[game.away_team_id] << game.home_goals

      teams_allowed_goals
    end
  end

  def average_games_teams_and_allowed_goals
    games_teams_and_allowed_goals.transform_values do |allowed_goals|
      average(allowed_goals.sum.to_f, allowed_goals.size)
    end
  end

  def all_teams_playing
    @game_teams.map {|game_team| game_team.team_id}.uniq
  end

  def away_win_percentage(team_id)
    away_wins = away_games(team_id).find_all do |game|
      game.result == "WIN"
    end
    percent = (away_wins.length / away_games(team_id).length.to_f) * 100
    percent.round(2)
  end

  def home_win_percentage(team_id)
    home_wins = home_games(team_id).find_all do |game|
      game.result == "WIN"
    end
    percent = (home_wins.length / home_games(team_id).length.to_f) * 100
    percent.round(2)
  end

  def home_games(team_id)
    @game_teams.find_all do |game_team|
      game_team.hoa == "home" && game_team.team_id == team_id
    end
  end

  def away_games(team_id)
    @game_teams.find_all do |game_team|
      game_team.hoa == "away" && game_team.team_id == team_id
    end
  end

  def home_teams_and_goals
    @games.reduce({}) do |home_games, game|
      hash_builder(home_games, game.home_team_id, game.home_goals)
    end
  end

  def average_home_teams_and_goals
    home_teams_and_goals.transform_values do |goals|
      average(goals.sum.to_f, goals.size)
    end
  end

  def game_team_results
    @game_teams.reduce({}) do |results_hash, game_team|
      hash_builder(results_hash, game_team.team_id, game_team.result)
    end
  end

  def percent_wins
    game_team_results.transform_values do |results|
      wins = (results.find_all { |result| result == "WIN"})
      percent(wins.length.to_f, results.length)
    end
  end

  def visiting_teams_and_goals
    @games.reduce({}) do |visitor_games, game|
      hash_builder(visitor_games, game.away_team_id, game.away_goals)
    end
  end

  def average_visiting_teams_and_goals
    visiting_teams_and_goals.transform_values do |goals|
      average(goals.sum.to_f, goals.size)
    end
  end

  def game_teams_that_season(team_id, season_id)
    @game_teams.find_all do |game_team|
      game_team.game_id.to_s[0..3] == season_id.to_s[0..3] && game_team.team_id == team_id
    end
  end

  def goals_to_shots_ratio_that_season(team_id, season_id)
    all_games = game_teams_that_season(team_id, season_id)
    all_goals = all_games.sum {|game_team| game_team.goals}
    all_shots = all_games.sum{|game_team| game_team.shots}
    (all_goals.to_f / all_shots).round(5)
  end

  def all_coaches
    @game_teams.map {|game_team| game_team.head_coach}.uniq
  end

  def create_hash_with_team_games_by_coach(season_id)
    all_coaches.reduce({}) do |coaches_with_games, coach|
      coaches_with_games[coach] = game_teams_that_season_by_coach(coach, season_id)
      coaches_with_games
    end
  end

  def game_teams_that_season_by_coach(coach, season_id)
    @game_teams.find_all do |game_team|
      game_team.game_id.to_s[0..3] == season_id.to_s[0..3] && game_team.head_coach == coach
    end
  end

  def finding_all_wins_by_coach(season_id)
    create_hash_with_team_games_by_coach(season_id).transform_values do |game_teams|
      (game_teams.find_all {|game| game.result == "WIN"}).length
    end
  end

  def number_of_games_by_coach(season_id)
    create_hash_with_team_games_by_coach(season_id).transform_values do |game_teams|
      game_teams.length
    end
  end

  def percent_wins_by_coach(season_id)
    percent_wins = {}
    finding_all_wins_by_coach(season_id).map do |coach, num_wins|
      percent_wins[coach] = (num_wins.to_f / number_of_games_by_coach(season_id)[coach]).round(2)
    end
    percent_wins
  end

  def game_id_by_team_id_and_season_type
    @games.reduce({}) do |teams_games_and_season_type, game|
      teams_games_and_season_type[game.away_team_id] = Hash.new{ |initialize_default, key| initialize_default[key] = [] } if teams_games_and_season_type[game.away_team_id].nil?
      teams_games_and_season_type[game.home_team_id] = Hash.new{ |initialize_default, key| initialize_default[key] = [] } if teams_games_and_season_type[game.home_team_id].nil?

      if game.type == "Postseason"
        teams_games_and_season_type[game.away_team_id][:post] << game.game_id
        teams_games_and_season_type[game.home_team_id][:post] << game.game_id
      elsif game.type == "Regular Season"
        teams_games_and_season_type[game.away_team_id][:regular] << game.game_id
        teams_games_and_season_type[game.home_team_id][:regular] << game.game_id
      end
      teams_games_and_season_type
    end
  end

  def game_team_postseason_results
    game_team_post_results = {}

    @game_teams.each do |game_team|
      game_team_post_results[game_team.team_id] = [] if game_team_post_results[game_team.team_id].nil?

      if game_id_by_team_id_and_season_type[game_team.team_id][:post].include?(game_team.game_id)
        game_team_post_results[game_team.team_id] << game_team.result
      end
    end
    game_team_post_results
  end

  def game_team_regular_season_results
    game_team_regular_results = {}

    @game_teams.each do |game_team|
      game_team_regular_results[game_team.team_id] = [] if game_team_regular_results[game_team.team_id].nil?

      if game_id_by_team_id_and_season_type[game_team.team_id][:regular].include?(game_team.game_id)
        game_team_regular_results[game_team.team_id] << game_team.result
      end
    end
    game_team_regular_results
  end

  def percent_wins_regular_season
    game_team_regular_season_results.transform_values do |results|
      wins = (results.find_all { |result| result == "WIN"})
      percent(wins.length.to_f, results.length)
    end
  end

  def percent_wins_postseason
    game_team_postseason_results.transform_values do |results|
      wins = (results.find_all { |result| result == "WIN"})
      percent(wins.length.to_f, results.length)
    end
  end

  def create_hash_with_team_games_by_team(season_id)
    all_teams_playing.reduce({}) do |teams_and_games, team_id|
      teams_and_games[team_id] = game_teams_that_season(team_id, season_id)
      teams_and_games
    end
  end

  def tackles_per_team_in_season(team_id, season_id)
    create_hash_with_team_games_by_team(season_id)[team_id].sum { |game_team| game_team.tackles }
  end
end
