require_relative 'statistics'

class SeasonStatistics < Statistics

  def initialize
    super
  end

  def most_accurate_team(season_id)
    teams_with_goals_to_shots_ratio = {}
    all_teams_playing.each do |team_id|
      teams_with_goals_to_shots_ratio[team_id] = goals_to_shots_ratio_that_season(team_id, season_id)
    end
    teams_with_goals_to_shots_ratio.delete_if { |id, ratio| ratio.nil? || ratio.nan?}
    highest = teams_with_goals_to_shots_ratio.max_by {|id, ratio| ratio}
    find_team_names(highest[0])
  end

  def least_accurate_team(season_id)
    teams_with_goals_to_shots_ratio = {}
    all_teams_playing.each do |team_id|
      teams_with_goals_to_shots_ratio[team_id] = goals_to_shots_ratio_that_season(team_id, season_id)
    end
    teams_with_goals_to_shots_ratio.delete_if { |id, ratio| ratio.nil? || ratio.nan?}
    lowest = teams_with_goals_to_shots_ratio.min_by {|id, ratio| ratio}
    find_team_names(lowest[0])
  end

  def winningest_coach(season_id)
    percent_wins_with_active_coaches = percent_wins_by_coach(season_id).delete_if {|coach, wins| wins.nan?}
    most_wins = percent_wins_with_active_coaches.max_by {|coach, percent| percent}
    most_wins[0]
  end

  def worst_coach(season_id)
    percent_wins_with_active_coaches = percent_wins_by_coach(season_id).delete_if {|coach, wins| wins.nan?}
    least_wins = percent_wins_with_active_coaches.min_by {|coach, percent| percent}
    least_wins[0]
  end

  def biggest_bust
    difference = percent_wins_regular_season.merge(percent_wins_postseason) do |team_id, reg, post|
      (reg - post).round(2)
    end

    find_team_names(hash_key_max_by(difference))
  end

  def biggest_surprise
    increase = percent_wins_regular_season.merge(percent_wins_postseason) do |team_id, reg, post|
      (post - reg).round(2)
    end
    find_team_names(hash_key_max_by(increase))
  end

  def most_tackles(season_id)
    team_id = all_teams_playing.max_by do |team|
      tackles_per_team_in_season(team, season_id)
    end
    find_team_names(team_id)
  end

  def fewest_tackles(season_id)
    array = []
    all_teams_playing.each do |team|
      if tackles_per_team_in_season(team, season_id) != 0
        array << team
      end
    end
    team_id = array.min_by do |team|
      tackles_per_team_in_season(team, season_id)
    end
    find_team_names(team_id)
  end
end
