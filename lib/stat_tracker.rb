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

  def home_win_percentage(team_id)
    home_wins = home_games(team_id).find_all do |game|
      game.result == "WIN"
    end
    percent = (home_wins.length / home_games(team_id).length.to_f) * 100
    percent.round(2)
  end

  def away_win_percentage(team_id)
    away_wins = away_games(team_id).find_all do |game|
      game.result == "WIN"
    end
    percent = (away_wins.length / home_games(team_id).length.to_f) * 100
    percent.round(2)
  end

  def all_teams_playing
    @game_teams.map {|game_team| game_team.team_id}.uniq
  end

  def change_team_id_to_name(team_id)
    that_team = teams.find {|team| team.team_id == team_id}
    that_team.team_name
  end

  def best_fans
    best_fans_team_id = all_teams_playing.max_by do |team_id|
      home_win_percentage(team_id) - away_win_percentage(team_id)
    end
    change_team_id_to_name(best_fans_team_id)
  end


  def worst_fans
    worst_fans_id = all_teams_playing.find_all do |team_id|
      away_win_percentage(team_id) > home_win_percentage(team_id)
    end
    worst_fans_id.map {|id| change_team_id_to_name(id)}
  end

# new code, iteration 4

  def gameid_of_games_that_season(season_id)
    games_that_season = @games.find_all {|game| game.season == season_id}
    games_that_season.map {|game| game.game_id}
  end


  def game_teams_that_season(team_id, season_id)
    @game_teams.find_all do |game_team|
      gameid_of_games_that_season(season_id).include?(game_team.game_id) && game_team.team_id == team_id
    end
  end

  def create_hash_with_team_games_by_team(season_id)
    all_teams_playing.reduce({}) do |teams_and_games, team_id|
      teams_and_games[team_id] = game_teams_that_season(team_id, season_id)
      teams_and_games
    end
  end

  def teams_with_goals_total(season_id)
    create_hash_with_team_games_by_team(season_id).transform_values do |game_team|
      game_team.sum{|game| game.goals}
    end
  end

  def teams_with_shots_total(season_id)
    create_hash_with_team_games_by_team(season_id).transform_values do |game_team|
      game_team.sum{|game| game.shots}
    end
  end

  def getting_goals_to_shots_ratio(season_id)
    goals_to_shots_ratio = {}
    teams_with_goals_total(season_id).map do |team_id, goals|
      goals_to_shots_ratio[team_id] = (goals.to_f / teams_with_shots_total(season_id)[team_id]).round(2)
    end
    goals_to_shots_ratio
  end

  def most_accurate_team(season_id)
    team = getting_goals_to_shots_ratio(season_id).max_by do |team_id, ratio|
      ratio
    end 
    change_team_id_to_name(team[0])
  end

  def least_accurate_team(season_id)
    team = getting_goals_to_shots_ratio(season_id).min_by {|team_id, ratio| ratio}
    change_team_id_to_name(team[0])
  end

end
