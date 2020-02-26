# require_relative 'calculable'
# require_relative 'hashable'
#
# module SeasonStatistics
#   include Calculable
#   include Hashable
#
#   def game_teams_that_season(team_id, season_id)
#     @game_teams.find_all do |game_team|
#       game_team.game_id.to_s[0..3] == season_id.to_s[0..3] && game_team.team_id == team_id
#     end
#   end
#
#   def goals_to_shots_ratio_that_season(team_id, season_id)
#     all_games = game_teams_that_season(team_id, season_id)
#     all_goals = all_games.sum {|game_team| game_team.goals}
#     all_shots = all_games.sum{|game_team| game_team.shots}
#     (all_goals.to_f / all_shots).round(5)
#   end
#
#   def most_accurate_team(season_id)
#     teams_with_goals_to_shots_ratio = {}
#     all_teams_playing.each do |team_id|
#       teams_with_goals_to_shots_ratio[team_id] = goals_to_shots_ratio_that_season(team_id, season_id)
#     end
#     teams_with_goals_to_shots_ratio.delete_if { |id, ratio| ratio.nil? || ratio.nan?}
#     highest = teams_with_goals_to_shots_ratio.max_by {|id, ratio| ratio}
#     find_team_names(highest[0])
#   end
#
#   def least_accurate_team(season_id)
#     teams_with_goals_to_shots_ratio = {}
#     all_teams_playing.each do |team_id|
#       teams_with_goals_to_shots_ratio[team_id] = goals_to_shots_ratio_that_season(team_id, season_id)
#     end
#     teams_with_goals_to_shots_ratio.delete_if { |id, ratio| ratio.nil? || ratio.nan?}
#     lowest = teams_with_goals_to_shots_ratio.min_by {|id, ratio| ratio}
#     find_team_names(lowest[0])
#   end
#
#   def all_coaches
#     @game_teams.map {|game_team| game_team.head_coach}.uniq
#   end
#
#   def create_hash_with_team_games_by_coach(season_id)
#     all_coaches.reduce({}) do |coaches_with_games, coach|
#       coaches_with_games[coach] = game_teams_that_season_by_coach(coach, season_id)
#       coaches_with_games
#     end
#   end
#
#   def game_teams_that_season_by_coach(coach, season_id)
#     @game_teams.find_all do |game_team|
#       game_team.game_id.to_s[0..3] == season_id.to_s[0..3] && game_team.head_coach == coach
#     end
#   end
#
#   def finding_all_wins_by_coach(season_id)
#     create_hash_with_team_games_by_coach(season_id).transform_values do |game_teams|
#       (game_teams.find_all {|game| game.result == "WIN"}).length
#     end
#   end
#
#   def number_of_games_by_coach(season_id)
#     create_hash_with_team_games_by_coach(season_id).transform_values do |game_teams|
#       game_teams.length
#     end
#   end
#
#   def percent_wins_by_coach(season_id)
#     percent_wins = {}
#     finding_all_wins_by_coach(season_id).map do |coach, num_wins|
#       percent_wins[coach] = (num_wins.to_f / number_of_games_by_coach(season_id)[coach]).round(2)
#     end
#     percent_wins
#   end
#
#   def winningest_coach(season_id)
#     percent_wins_with_active_coaches = percent_wins_by_coach(season_id).delete_if {|coach, wins| wins.nan?}
#     most_wins = percent_wins_with_active_coaches.max_by {|coach, percent| percent}
#     most_wins[0]
#   end
#
#   def worst_coach(season_id)
#     percent_wins_with_active_coaches = percent_wins_by_coach(season_id).delete_if {|coach, wins| wins.nan?}
#     least_wins = percent_wins_with_active_coaches.min_by {|coach, percent| percent}
#     least_wins[0]
#   end
#
#   def game_id_by_team_id_and_season_type
#     @games.reduce({}) do |teams_games_and_season_type, game|
#       teams_games_and_season_type[game.away_team_id] = Hash.new{ |initialize_default, key| initialize_default[key] = [] } if teams_games_and_season_type[game.away_team_id].nil?
#       teams_games_and_season_type[game.home_team_id] = Hash.new{ |initialize_default, key| initialize_default[key] = [] } if teams_games_and_season_type[game.home_team_id].nil?
#
#       if game.type == "Postseason"
#         teams_games_and_season_type[game.away_team_id][:post] << game.game_id
#         teams_games_and_season_type[game.home_team_id][:post] << game.game_id
#       elsif game.type == "Regular Season"
#         teams_games_and_season_type[game.away_team_id][:regular] << game.game_id
#         teams_games_and_season_type[game.home_team_id][:regular] << game.game_id
#       end
#       teams_games_and_season_type
#     end
#   end
#
#   def game_team_postseason_results
#     game_team_post_results = {}
#
#     @game_teams.each do |game_team|
#       game_team_post_results[game_team.team_id] = [] if game_team_post_results[game_team.team_id].nil?
#
#       if game_id_by_team_id_and_season_type[game_team.team_id][:post].include?(game_team.game_id)
#         game_team_post_results[game_team.team_id] << game_team.result
#       end
#     end
#     game_team_post_results
#   end
#
#   def game_team_regular_season_results
#     game_team_regular_results = {}
#
#     @game_teams.each do |game_team|
#       game_team_regular_results[game_team.team_id] = [] if game_team_regular_results[game_team.team_id].nil?
#
#       if game_id_by_team_id_and_season_type[game_team.team_id][:regular].include?(game_team.game_id)
#         game_team_regular_results[game_team.team_id] << game_team.result
#       end
#     end
#     game_team_regular_results
#   end
#
#   def percent_wins_regular_season
#     game_team_regular_season_results.transform_values do |results|
#       wins = (results.find_all { |result| result == "WIN"})
#       percent(wins.length.to_f, results.length)
#     end
#   end
#
#   def percent_wins_postseason
#     game_team_postseason_results.transform_values do |results|
#       wins = (results.find_all { |result| result == "WIN"})
#       percent(wins.length.to_f, results.length)
#     end
#   end
#
#   def biggest_bust
#     difference = percent_wins_regular_season.merge(percent_wins_postseason) do |team_id, reg, post|
#       (reg - post).round(2)
#     end
#
#     find_team_names(hash_key_max_by(difference))
#   end
#
#   def biggest_surprise
#     increase = percent_wins_regular_season.merge(percent_wins_postseason) do |team_id, reg, post|
#       (post - reg).round(2)
#     end
#     find_team_names(hash_key_max_by(increase))
#   end
#
#   def find_games_in_season(season)
#     @games.find_all do |game|
#       game.season == season
#     end
#   end
#
#   def gameid_of_games_that_season(season_id)
#     games_that_season = @games.find_all {|game| game.season == season_id}
#     games_that_season.map {|game| game.game_id}
#   end
#
#   # def game_teams_that_season(team_id, season_id)
#   #   @game_teams.find_all do |game_team|
#   #     gameid_of_games_that_season(season_id).include?(game_team.game_id) && game_team.team_id == team_id
#   #   end
#   # end
#
#   def create_hash_with_team_games_by_team(season_id)
#     all_teams_playing.reduce({}) do |teams_and_games, team_id|
#       teams_and_games[team_id] = game_teams_that_season(team_id, season_id)
#       teams_and_games
#     end
#   end
#
#   def tackles_per_team_in_season(team_id, season_id)
#     create_hash_with_team_games_by_team(season_id)[team_id].sum { |game_team| game_team.tackles }
#   end
#
#   def most_tackles(season_id)
#     team_id = all_teams_playing.max_by do |team|
#       tackles_per_team_in_season(team, season_id)
#     end
#     find_team_names(team_id)
#   end
#
#   def fewest_tackles(season_id)
#     array = []
#     all_teams_playing.each do |team|
#       if tackles_per_team_in_season(team, season_id) != 0
#         array << team
#       end
#     end
#     team_id = array.min_by do |team|
#       tackles_per_team_in_season(team, season_id)
#     end
#     find_team_names(team_id)
#   end
# end
