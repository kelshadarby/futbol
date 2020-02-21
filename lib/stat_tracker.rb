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


  def best_fans
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
      game.results == "WIN"
    end
    home_wins/home_games(team_id).length
  end

  def away_win_percentage(team_id)
    away_wins = away_games(team_id).find_all do |game|
      game.results == "WIN"
    end
    home_wins/home_games(team_id).length
  end

end
