-- schema-sqlite.sql: FMRD-Summary schema for SQLite
-- Derived from: fmrd-sqlite.sql: FMRD schema for SQLite
-- Developed by: Soccermetrics Research (2012-08-21)
-- Licensing information in LICENSE.txt

PRAGMA foreign_keys = ON;

-- -------------------------------------------------
-- Personnel Tables
-- -------------------------------------------------

-- Confederation table
CREATE TABLE tbl_confederations (
	confed_id	integer PRIMARY KEY,
	confed_name	varchar(40) NOT NULL
	);

-- Country table
CREATE TABLE tbl_countries (
	country_id	    integer PRIMARY KEY,
	confed_id	    integer REFERENCES tbl_confederations(confed_id),
	country_name	varchar(60) NOT NULL
	);

-- Position table
CREATE TABLE tbl_positions (
	position_id		integer PRIMARY KEY,
	position_name	varchar(15) NOT NULL
	);

-- Player table
CREATE TABLE tbl_players (
	player_id		integer PRIMARY KEY,
	country_id		integer REFERENCES tbl_countries(country_id),
	plyr_birthdate  text NOT NULL,
	plyr_firstname	varchar(20) NOT NULL,
	plyr_lastname	varchar(30) NOT NULL,
	plyr_nickname	varchar(30) NULL,
	plyr_defposid	integer REFERENCES tbl_positions(position_id)
	);
	
-- Manager table
CREATE TABLE tbl_managers (
	manager_id			integer PRIMARY KEY,
	country_id			integer REFERENCES tbl_countries(country_id),
	mgr_birthdate	    text NOT NULL,
	mgr_firstname		varchar(20) NOT NULL,
	mgr_lastname		varchar(30) NOT NULL,
	mgr_nickname		varchar(30) NULL
	);

-- Referee table
CREATE TABLE tbl_referees (
	referee_id			integer PRIMARY KEY,
	country_id			integer REFERENCES tbl_countries(country_id),
	ref_birthdate		text NOT NULL,
	ref_firstname		varchar(20) NOT NULL,
	ref_lastname		varchar(30) NOT NULL
	);

-- -------------------------------------------------
-- Match Overview Tables
-- -------------------------------------------------

-- Competitions table
CREATE TABLE tbl_competitions (
	competition_id	integer PRIMARY KEY,
	comp_name		varchar(100) NOT NULL
	);
	
-- (League) Rounds table	
CREATE TABLE tbl_rounds (
	round_id	integer PRIMARY KEY,
	round_desc 	varchar(20) NOT NULL
	);
	
-- Teams table	
CREATE TABLE tbl_teams (
	team_id 	integer PRIMARY KEY,
    country_id  integer REFERENCES tbl_countries(country_id),
	team_name	varchar(50) NOT NULL
	);		
	
-- Venues table
CREATE TABLE tbl_venues (
	venue_id		integer PRIMARY KEY,
	team_id			integer REFERENCES tbl_teams(team_id),
	country_id		integer REFERENCES tbl_countries(country_id),
	ven_city		varchar(40) NOT NULL,
	ven_name		varchar(40) NOT NULL
	);

-- Match table
CREATE TABLE tbl_matches (
	match_id				integer PRIMARY KEY,
	match_date				text,
	match_firsthalftime	 	integer DEFAULT 45 CHECK (match_firsthalftime > 0),
	match_secondhalftime 	integer DEFAULT 45 CHECK (match_secondhalftime >= 0),
	match_attendance		integer DEFAULT 0 CHECK (match_attendance >= 0),
	competition_id			integer REFERENCES tbl_competitions(competition_id),
	round_id                integer REFERENCES tbl_rounds(round_id),
	venue_id				integer REFERENCES tbl_venues(venue_id),
	referee_id				integer REFERENCES tbl_referees(referee_id)
	);
	
-- Lineup table
CREATE TABLE tbl_lineups (
	lineup_id		integer PRIMARY KEY,
	match_id		integer REFERENCES tbl_matches(match_id),
	team_id			integer REFERENCES tbl_teams(team_id),
	player_id		integer REFERENCES tbl_players(player_id),
	position_id		integer REFERENCES tbl_positions(position_id),
	lp_starting		boolean DEFAULT FALSE,
	lp_captain		boolean DEFAULT FALSE
	);
		
-- ---------------------------------------
-- Linking tables to Match Overview tables
-- ---------------------------------------

-- Home/away teams
CREATE TABLE tbl_hometeams (
	match_id	integer REFERENCES tbl_matches(match_id),
	team_id		integer	REFERENCES tbl_teams(team_id),
	PRIMARY KEY (match_id, team_id)
	);
	
CREATE TABLE tbl_awayteams (
	match_id	integer REFERENCES tbl_matches(match_id),
	team_id		integer	REFERENCES tbl_teams(team_id),
	PRIMARY KEY (match_id, team_id)
	);	

-- Home/away managers	
CREATE TABLE tbl_homemanagers (
	match_id	integer REFERENCES tbl_matches(match_id),
	manager_id	integer	REFERENCES tbl_managers(manager_id),
	PRIMARY KEY (match_id, manager_id)
	);
	
CREATE TABLE tbl_awaymanagers (
	match_id	integer REFERENCES tbl_matches(match_id),
	manager_id	integer	REFERENCES tbl_managers(manager_id),
	PRIMARY KEY (match_id, manager_id)
	);	
	
-- -------------------------------------------------
-- Match Event Tables
-- -------------------------------------------------

-- Goals table	
CREATE TABLE tbl_goals (
	goal_id			integer PRIMARY KEY,
	team_id			integer REFERENCES tbl_teams(team_id),
	lineup_id		integer REFERENCES tbl_lineups(lineup_id),
	gls_time		integer NOT NULL CHECK (gls_time > 0 AND gls_time <= 120),
	gls_stime		integer DEFAULT 0 CHECK (gls_stime >= 0 AND gls_stime <= 15)
	);
	
-- Cards table
CREATE TABLE tbl_cards (
	card_id			integer PRIMARY KEY,
	card_type		varchar(12) NOT NULL
	);
	
-- Offenses table
CREATE TABLE tbl_offenses (
	offense_id		integer PRIMARY KEY,
	lineup_id		integer REFERENCES tbl_lineups(lineup_id),
	card_id			integer REFERENCES tbl_cards(card_id),
	ofns_time		integer NOT NULL CHECK (ofns_time > 0 AND ofns_time <= 120),
	ofns_stime		integer DEFAULT 0 CHECK (ofns_stime >= 0 AND ofns_stime <= 15)
	);

-- Penalty Outcomes table
CREATE TABLE tbl_penoutcomes (
	penoutcome_id	integer PRIMARY KEY,
	po_desc			varchar(15) NOT NULL
	);

-- Penalties table
CREATE TABLE tbl_penalties (
	penalty_id		integer PRIMARY KEY,
	lineup_id		integer REFERENCES tbl_lineups(lineup_id),
	penoutcome_id	integer REFERENCES tbl_penoutcomes(penoutcome_id),
	pen_time		integer NOT NULL CHECK (pen_time > 0 AND pen_time <= 120),
	pen_stime		integer DEFAULT 0 CHECK (pen_stime >= 0 AND pen_stime <= 15)
	);
	
-- Substitutions table
CREATE TABLE tbl_substitutions (
	subs_id			integer PRIMARY KEY,
	subs_time		integer NOT NULL CHECK (subs_time > 0 AND subs_time <= 120),
	subs_stime		integer DEFAULT 0 CHECK (subs_stime >= 0 AND subs_stime <= 15)
	);

-- In Substitutions table
CREATE TABLE tbl_insubstitutions (
	subs_id			integer REFERENCES tbl_substitutions(subs_id),
	lineup_id		integer	REFERENCES tbl_lineups(lineup_id),
	PRIMARY KEY (subs_id, lineup_id)
	);

-- Out Substitutions table
CREATE TABLE tbl_outsubstitutions (
	subs_id			integer REFERENCES tbl_substitutions(subs_id),
	lineup_id		integer	REFERENCES tbl_lineups(lineup_id),
	PRIMARY KEY (subs_id, lineup_id)
	);

-- -------------------------------------------------
-- Summary Statistics Tables
-- -------------------------------------------------



