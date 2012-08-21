-- views-sqlite.sql: View schema (SQLite3 format) for FMRD-Summary
-- Derived from: fmrd-views-sqlite.sql: View schema (SQLite3 format) for FMRD
-- Developed by: Soccermetrics Research (2012-08-21)
-- Licensing information in LICENSE.txt

-- -------------------------------------------------
-- CountriesList View
-- -------------------------------------------------

CREATE VIEW countries_list AS
	SELECT country_id,
				 cty_name AS country,
				 confed_name AS confed
	FROM tbl_countries, tbl_confederations
	WHERE tbl_countries.confed_id = tbl_confederations.confed_id;

-- -------------------------------------------------
-- TeamsList View
-- -------------------------------------------------

CREATE VIEW teams_list AS
	SELECT team_id,
		   tm_name AS team_name,
		   cty_name AS country
	FROM tbl_teams, tbl_countries
	WHERE tbl_teams.country_id = tbl_countries.country_id;
				 
-- -------------------------------------------------
-- PlayersList View
-- -------------------------------------------------

CREATE VIEW players_list AS
	SELECT player_id,
			CASE WHEN plyr_nickname IS NOT NULL 
			THEN plyr_nickname
			ELSE plyr_firstname || ' ' || plyr_lastname
			END AS full_name,
			CASE WHEN plyr_nickname IS NOT NULL 
			THEN plyr_nickname
			ELSE plyr_lastname
			END AS sort_name,				 
			position_name AS position,
			plyr_birthdate AS birthdate,
			country
	FROM tbl_players, countries_list, tbl_positions
	WHERE tbl_players.country_id = countries_list.country_id
	  AND tbl_players.plyr_defposid = tbl_positions.position_id;		

-- -------------------------------------------------
-- ManagersList View
-- -------------------------------------------------

CREATE VIEW managers_list AS
	SELECT manager_id,
			CASE WHEN mgr_nickname IS NOT NULL THEN mgr_nickname
			ELSE mgr_firstname || ' ' || mgr_lastname
			END AS full_name,
			CASE WHEN mgr_nickname IS NOT NULL THEN mgr_nickname
			ELSE mgr_lastname
			END AS sort_name,				 				 
			mgr_birthdate AS birthdate,
			country
	FROM tbl_managers, countries_list
	WHERE tbl_managers.country_id = countries_list.country_id;		

-- -------------------------------------------------
-- RefereesList View
-- -------------------------------------------------

CREATE VIEW referees_list AS
	SELECT referee_id,
			ref_firstname || ' ' || ref_lastname AS full_name,
			ref_lastname AS sort_name,
			ref_birthdate AS birthdate,
			country
	FROM tbl_referees, countries_list
	WHERE tbl_referees.country_id = countries_list.country_id;		

-- -------------------------------------------------
-- HomeTeamList View
-- -------------------------------------------------

CREATE VIEW hometeam_list AS
	SELECT tbl_matches.match_id,
			tm_name AS team
	FROM tbl_matches, tbl_hometeams, tbl_teams
	WHERE tbl_matches.match_id = tbl_hometeams.match_id
		AND tbl_hometeams.team_id = tbl_teams.team_id;

-- -------------------------------------------------
-- AwayTeamList View
-- -------------------------------------------------

CREATE VIEW awayteam_list AS
	SELECT tbl_matches.match_id,
			tm_name AS team
	FROM tbl_matches, tbl_awayteams, tbl_teams
	WHERE tbl_matches.match_id = tbl_awayteams.match_id
		AND tbl_awayteams.team_id = tbl_teams.team_id;

-- -------------------------------------------------
-- VenueList View
-- -------------------------------------------------

CREATE VIEW venue_list AS
	SELECT venue_id,
				 ven_name AS venue,
				 ven_city AS city,
				 country,
	FROM tbl_venues, countries_list
	WHERE countries_list.country_id = tbl_venues.country_id;				

-- -------------------------------------------------
-- MatchList View
-- -------------------------------------------------

CREATE VIEW match_list AS
	SELECT tbl_matches.match_id,
				 tbl_competitions.competition_id,
				 comp_name AS competition,
				 match_date,
				 round_desc AS matchday,
				 hometeam_list.team || ' vs ' || awayteam_list.team AS matchup,
				 venue,
				 full_name AS referee
	FROM tbl_matches, tbl_competitions, hometeam_list, awayteam_list, venue_list, referees_list
	WHERE hometeam_list.match_id = tbl_matches.match_id
		AND awayteam_list.match_id = tbl_matches.match_id
		AND tbl_competitions.competition_id = tbl_matches.competition_id
		AND venue_list.venue_id = tbl_matches.venue_id
		AND referees_list.referee_id = tbl_matches.referee_id;
		
-- -------------------------------------------------
-- LineupList View
-- -------------------------------------------------

CREATE VIEW lineup_list AS
	SELECT lineup_id,
				 matchup,
				 tm_name AS team,
				 full_name AS player,
				 sort_name,
				 position,
				 lp_starting AS starter,
				 lp_captain AS captain
	FROM tbl_teams, players_list, tbl_positions, match_list, tbl_lineups
	WHERE tbl_lineups.team_id = tbl_teams.team_id
	  AND tbl_lineups.match_id = match_list.match_id 
	  AND players_list.player_id = tbl_lineups.player_id
	  AND tbl_lineups.position_id = tbl_positions.position_id;
	  
-- -------------------------------------------------
-- GoalsList View
-- -------------------------------------------------

CREATE VIEW goals_list AS
	SELECT goal_id,
				 match_list.matchup,
				 tm_name AS team,
				 player AS scorer,
				 CASE WHEN gls_stime = 0 THEN gls_time || ''''
				 ELSE gls_time || '+' || gls_stime || ''''
				 END AS time
	FROM tbl_teams, match_list, lineup_list, tbl_goals
	WHERE match_list.match_id IN (SELECT match_id FROM tbl_lineups 
	                              WHERE tbl_lineups.lineup_id = tbl_goals.lineup_id)
	  AND tbl_goals.lineup_id = lineup_list.lineup_id
	  AND tbl_goals.team_id = tbl_teams.team_id;

-- -------------------------------------------------
-- OwnGoalsList View
-- -------------------------------------------------

CREATE VIEW owngoals_list AS
	SELECT goal_id,
				 match_list.matchup,
				 tm_name AS team,
				 player AS scorer,
				 CASE WHEN gls_stime = 0 THEN gls_time || ''''
				 ELSE gls_time || '+' || gls_stime || ''''
				 END AS time
	FROM tbl_teams, match_list, lineup_list, tbl_goals
	WHERE match_list.match_id IN (SELECT match_id FROM tbl_lineups
								WHERE tbl_goals.lineup_id = tbl_lineups.lineup_id)
	    AND tbl_goals.lineup_id = lineup_list.lineup_id
	    AND tbl_goals.team_id NOT IN (SELECT team_id FROM tbl_lineups
	  								WHERE tbl_lineups.lineup_id = lineup_list.lineup_id);

-- -------------------------------------------------
-- PenaltiesList View
-- -------------------------------------------------

CREATE VIEW penalties_list AS
	SELECT penalty_id,
				 matchup,
				 team,
				 player AS taker,
				 po_desc AS outcome,
				 CASE WHEN pen_stime = 0 THEN pen_time || ''''
				 ELSE pen_time || '+' || pen_stime || ''''
				 END AS time
	FROM tbl_penalties, lineup_list, tbl_penoutcomes
	WHERE tbl_penalties.penoutcome_id = tbl_penoutcomes.penoutcome_id
	  AND tbl_penalties.lineup_id = lineup_list.lineup_id;				 

-- -------------------------------------------------
-- CautionsList View
-- -------------------------------------------------

CREATE VIEW cautions_list AS
	SELECT offense_id,
				 matchup,
				 team,
				 player,
				 CASE WHEN ofns_stime = 0 THEN ofns_time || ''''
				 ELSE ofns_time || '+' || ofns_stime || ''''
				 END AS time
	FROM tbl_offenses, lineup_list
	WHERE tbl_offenses.lineup_id = lineup_list.lineup_id
		AND tbl_offenses.card_id IN (SELECT card_id FROM tbl_cards
				WHERE card_type = 'Yellow');

-- -------------------------------------------------
-- ExpulsionsList View
-- -------------------------------------------------

CREATE VIEW expulsions_list AS
	SELECT offense_id,
				 matchup,
				 team,
				 player,
				 CASE WHEN ofns_stime = 0 THEN ofns_time || ''''
				 ELSE ofns_time || '+' || ofns_stime || ''''
				 END AS time
	FROM tbl_offenses, lineup_list
	WHERE tbl_offenses.lineup_id = lineup_list.lineup_id
		AND tbl_offenses.card_id IN (SELECT card_id FROM tbl_cards
				WHERE card_type IN ('Yellow/Red','Red'));

-- -------------------------------------------------
-- SubstitutionsList View
-- -------------------------------------------------

CREATE VIEW insub_list AS
	SELECT subs_id, player
	FROM tbl_insubstitutions, lineup_list
	WHERE tbl_insubstitutions.lineup_id = lineup_list.lineup_id;
	
CREATE VIEW outsub_list AS
	SELECT subs_id, player
	FROM tbl_outsubstitutions, lineup_list
	WHERE tbl_outsubstitutions.lineup_id = lineup_list.lineup_id;

CREATE VIEW subs_list AS
    SELECT tbl_substitutions.subs_id, 
           a1.matchup, 
           a1.team, 
           a1.player AS in_player, 
           a2.player AS out_player, 
           CASE WHEN subs_stime = 0 THEN subs_time || '''' 
           ELSE subs_time || '+' || subs_stime || '''' 
           END AS time FROM lineup_list a1, lineup_list a2, tbl_substitutions                                                                     
    INNER JOIN tbl_insubstitutions ON tbl_substitutions.subs_id = tbl_insubstitutions.subs_id
    INNER JOIN tbl_outsubstitutions ON tbl_substitutions.subs_id = tbl_outsubstitutions.subs_id
    WHERE a1.lineup_id = tbl_insubstitutions.lineup_id
      AND a2.lineup_id = tbl_outsubstitutions.lineup_id
      AND a1.team = a2.team
      AND a1.matchup = a2.matchup;
	
