require_relative 'statistics'

class LeagueStatistics < Statistics

  def initialize
    super
  end

  def count_of_teams
    @teams.size
  end

  def best_offense
    find_team_names(hash_key_max_by(average_goals_per_team))
  end

  def worst_offense
    find_team_names(hash_key_min_by(average_goals_per_team))
  end

  def best_defense
    find_team_names(hash_key_min_by(average_games_teams_and_allowed_goals))
  end

  def worst_defense
    find_team_names(hash_key_max_by(average_games_teams_and_allowed_goals))
  end

  def highest_scoring_visitor
    find_team_names(hash_key_max_by(average_visiting_teams_and_goals))
  end

  def lowest_scoring_visitor
    find_team_names(hash_key_min_by(average_visiting_teams_and_goals))
  end

  def highest_scoring_home_team
    find_team_names(hash_key_max_by(average_home_teams_and_goals))
  end

  def lowest_scoring_home_team
    find_team_names(hash_key_min_by(average_home_teams_and_goals))
  end

  def winningest_team
    find_team_names(hash_key_max_by(percent_wins))
  end

  def best_fans
    best_fans_team_id = all_teams_playing.max_by do |team_id|
      home_win_percentage(team_id) - away_win_percentage(team_id)
    end
    find_team_names(best_fans_team_id)
  end

  def worst_fans
    worst_fans_id = all_teams_playing.find_all do |team_id|
      away_win_percentage(team_id) > home_win_percentage(team_id)
    end
    worst_fans_id.map {|id| find_team_names(id)}
  end
end
