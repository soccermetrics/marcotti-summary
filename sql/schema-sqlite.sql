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
	plyr_birthdate  text DEFAULT '0000-00-00',
	plyr_firstname	varchar(20) NOT NULL,
	plyr_lastname	varchar(30) NOT NULL,
	plyr_nickname	varchar(30) NULL,
	plyr_defposid	integer REFERENCES tbl_positions(position_id)
	);
	
-- Manager table
CREATE TABLE tbl_managers (
	manager_id			integer PRIMARY KEY,
	country_id			integer REFERENCES tbl_countries(country_id),
	mgr_birthdate	    text DEFAULT '0000-00-00',
	mgr_firstname		varchar(20) NOT NULL,
	mgr_lastname		varchar(30) NOT NULL,
	mgr_nickname		varchar(30) NULL
	);

-- Referee table
CREATE TABLE tbl_referees (
	referee_id			integer PRIMARY KEY,
	country_id			integer REFERENCES tbl_countries(country_id),
	ref_birthdate		text DEFAULT '0000-00-00',
	ref_firstname		varchar(20) NOT NULL,
	ref_lastname		varchar(30) NOT NULL
	);

-- -------------------------------------------------
-- Match Overview Tables
-- -------------------------------------------------

-- Competitions table
CREATE TABLE tbl_competitions (
	competition_id	    integer PRIMARY KEY,
	competition_name	varchar(100) NOT NULL
	);
	
-- Seasons table
CREATE TABLE tbl_seasons (
	season_id	integer PRIMARY KEY,
	season_name	varchar(20) NOT NULL
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

CREATE TABLE tbl_assists (
    summary_id  integer PRIMARY KEY,
    lineup_id   integer REFERENCES tbl_lineups,
    corners     integer DEFAULT 0 CHECK (corners >= 0),
    freekicks   integer DEFAULT 0 CHECK (freekicks >= 0),
    throwins    integer DEFAULT 0 CHECK (throwins >= 0),
    goalkicks   integer DEFAULT 0 CHECK (goalkicks >= 0),
    setpieces   integer DEFAULT 0 CHECK (setpieces >= 0),
    total       integer DEFAULT 0 CHECK (total >= 0)
    );
    
CREATE TABLE tbl_clearances (
    summary_id  integer PRIMARY KEY,
    lineup_id   integer REFERENCES tbl_lineups,
    headed      integer DEFAULT 0 CHECK (headed >= 0),
    goalline    integer DEFAULT 0 CHECK (goalline >= 0),
    other       integer DEFAULT 0 CHECK (other >= 0),
    total       integer DEFAULT 0 CHECK (total >= 0)    
    );
    
CREATE TABLE tbl_corners (
    summary_id      integer PRIMARY KEY,
    lineup_id       integer REFERENCES tbl_lineups,
    penbox_success  integer DEFAULT 0 CHECK (penbox_success >= 0),
    penbox_failure  integer DEFAULT 0 CHECK (penbox_failure >= 0),
    left_success    integer DEFAULT 0 CHECK (left_success >= 0),
    left_failure    integer DEFAULT 0 CHECK (left_failure >= 0),
    right_success   integer DEFAULT 0 CHECK (right_success >= 0),
    right_failure   integer DEFAULT 0 CHECK (right_failure >= 0),
    short           integer DEFAULT 0 CHECK (short >= 0),
    total           integer DEFAULT 0 CHECK (total >= 0)    
    );
    
CREATE TABLE tbl_cornercrosses (
    summary_id      integer PRIMARY KEY,
    lineup_id       integer REFERENCES tbl_lineups,
    total_success   integer DEFAULT 0 CHECK (total_success >= 0),
    total_failure   integer DEFAULT 0 CHECK (total_failure >= 0),
    air_success     integer DEFAULT 0 CHECK (air_success >= 0),
    air_failure     integer DEFAULT 0 CHECK (air_failure >= 0),
    left_success    integer DEFAULT 0 CHECK (left_success >= 0),
    left_failure    integer DEFAULT 0 CHECK (left_failure >= 0),
    right_success   integer DEFAULT 0 CHECK (right_success >= 0),
    right_failure   integer DEFAULT 0 CHECK (right_failure >= 0),
    );

CREATE TABLE tbl_crosses (
    summary_id      integer PRIMARY KEY,
    lineup_id       integer REFERENCES tbl_lineups,
    total_success   integer DEFAULT 0 CHECK (total_success >= 0),
    total_failure   integer DEFAULT 0 CHECK (total_failure >= 0),
    air_success     integer DEFAULT 0 CHECK (air_success >= 0),
    air_failure     integer DEFAULT 0 CHECK (air_failure >= 0),
    openplay_success   integer DEFAULT 0 CHECK (openplay_success >= 0),
    openplay_failure   integer DEFAULT 0 CHECK (openplay_failure >= 0),
    left_success    integer DEFAULT 0 CHECK (left_success >= 0),
    left_failure    integer DEFAULT 0 CHECK (left_failure >= 0),
    right_success   integer DEFAULT 0 CHECK (right_success >= 0),
    right_failure   integer DEFAULT 0 CHECK (right_failure >= 0),
    );

CREATE TABLE tbl_defensives (
    summary_id          integer PRIMARY KEY,
    lineup_id           integer REFERENCES tbl_lineups,
    blocks              integer DEFAULT 0 CHECK (blocks >= 0),
    interceptions       integer DEFAULT 0 CHECK (interceptions >= 0),
    recoveries          integer DEFAULT 0 CHECK (recoveries >= 0),
    corners_conceded    integer DEFAULT 0 CHECK (corners_conceded >= 0),
    fouls_conceded      integer DEFAULT 0 CHECK (fouls_conceded >= 0),
    challenges_lost     integer DEFAULT 0 CHECK (challenges_lost >= 0),
    handballs_conceded  integer DEFAULT 0 CHECK (handballs_conceded >= 0),
    penalties_conceded  integer DEFAULT 0 CHECK (penalties_conceded >= 0),
    error_goals         integer DEFAULT 0 CHECK (error_goals >= 0),
    error_shots         integer DEFAULT 0 CHECK (error_shots >= 0)    
    );

CREATE TABLE tbl_discipline (
    summary_id   integer PRIMARY KEY,
    lineup_id    integer REFERENCES tbl_lineups,
    yellows      integer DEFAULT 0 CHECK (error_goals >= 0),
    reds         integer DEFAULT 0 CHECK (error_shots >= 0)
    );
    
CREATE TABLE tbl_duels (
    summary_id   integer PRIMARY KEY,
    lineup_id    integer REFERENCES tbl_lineups,
    total_won    integer DEFAULT 0 CHECK (total_won >= 0),
    total_lost   integer DEFAULT 0 CHECK (total_lost >= 0)
    aerial_won   integer DEFAULT 0 CHECK (aerial_won >= 0),
    aerial_lost  integer DEFAULT 0 CHECK (aerial_lost >= 0)
    ground_won   integer DEFAULT 0 CHECK (ground_won >= 0),
    ground_lost  integer DEFAULT 0 CHECK (ground_lost >= 0)
    );
    
CREATE TABLE tbl_foulwins (
    summary_id      integer PRIMARY KEY,
    lineup_id       integer REFERENCES tbl_lineups,
    total           integer DEFAULT 0 CHECK (total >= 0),
    total_danger    integer DEFAULT 0 CHECK (total_danger >= 0)
    total_penalty   integer DEFAULT 0 CHECK (total_penalty >= 0),
    total_nodanger  integer DEFAULT 0 CHECK (total_nodanger >= 0)
    );
    
CREATE TABLE tbl_freekicks (
    summary_id  integer PRIMARY KEY,
    lineup_id   integer REFERENCES tbl_lineups,
    ontarget    integer DEFAULT 0 CHECK (ontarget >= 0),
    offtarget   integer DEFAULT 0 CHECK (offtarget >= 0)
    );

CREATE TABLE tbl_gkallowedgoals (
    summary_id  integer PRIMARY KEY,
    lineup_id   integer REFERENCES tbl_lineups,
    insidebox   integer DEFAULT 0 CHECK (insidebox >= 0),
    outsidebox  integer DEFAULT 0 CHECK (outsidebox >= 0),
    cleansheet  boolean DEFAULT FALSE    
    );
    
CREATE TABLE tbl_gksaves (
    summary_id  integer PRIMARY KEY,
    lineup_id   integer REFERENCES tbl_lineups,
    insidebox   integer DEFAULT 0 CHECK (insidebox >= 0),
    outsidebox  integer DEFAULT 0 CHECK (outsidebox >= 0),
    penalty     integer DEFAULT 0 CHECK (penalty >= 0)    
    );
    
CREATE TABLE tbl_gkallowedshots (
    summary_id  integer PRIMARY KEY,
    lineup_id   integer REFERENCES tbl_lineups,
    insidebox   integer DEFAULT 0 CHECK (insidebox >= 0),
    outsidebox  integer DEFAULT 0 CHECK (outsidebox >= 0),
    bigchances  integer DEFAULT 0 CHECK (bigchances >= 0)    
    );
    
CREATE TABLE tbl_gkactions (
    summary_id      integer PRIMARY KEY,
    lineup_id       integer REFERENCES tbl_lineups,
    catches         integer DEFAULT 0 CHECK (catches >= 0),
    punches         integer DEFAULT 0 CHECK (punches >= 0),
    crosses_noclaim integer DEFAULT 0 CHECK (crosses_noclaim >= 0),
    distrib_success integer DEFAULT 0 CHECK (distrib_success >= 0),
    distrib_failure integer DEFAULT 0 CHECK (distrib_failure >= 0)    
    );
    
CREATE TABLE tbl_goalbodyparts (
    summary_id  integer PRIMARY KEY,
    lineup_id   integer REFERENCES tbl_lineups,
    headed      integer DEFAULT 0 CHECK (headed >= 0),
    leftfoot    integer DEFAULT 0 CHECK (leftfoot >= 0),
    rightfoot   integer DEFAULT 0 CHECK (rightfoot >= 0)    
    );

CREATE TABLE tbl_goallocations (
    summary_id  integer PRIMARY KEY,
    lineup_id   integer REFERENCES tbl_lineups,
    insidebox   integer DEFAULT 0 CHECK (insidebox >= 0),
    outsidebox  integer DEFAULT 0 CHECK (outsidebox >= 0)
    );
    
CREATE TABLE tbl_goaltotals (
    summary_id  integer PRIMARY KEY,
    lineup_id   integer REFERENCES tbl_lineups,
    firstgoal   boolean DEFAULT FALSE,
    winner      boolean DEFAULT FALSE,
    freekick    integer DEFAULT 0 CHECK (freekick >= 0),
    openplay    integer DEFAULT 0 CHECK (openplay >= 0),
    corners     integer DEFAULT 0 CHECK (corners >= 0),
    throwins    integer DEFAULT 0 CHECK (throwins >= 0),
    penalties   integer DEFAULT 0 CHECK (penalties >= 0),
    substitute  integer DEFAULT 0 CHECK (substitute >= 0),
    other       integer DEFAULT 0 CHECK (other >= 0)
    );

CREATE TABLE tbl_keyplays (
    summary_id  integer PRIMARY KEY,
    lineup_id   integer REFERENCES tbl_lineups,
    corners     integer DEFAULT 0 CHECK (corners >= 0)
    freekicks   integer DEFAULT 0 CHECK (freekicks >= 0),
    throwins    integer DEFAULT 0 CHECK (throwins >= 0)
    goalkicks   integer DEFAULT 0 CHECK (goalkicks >= 0),
    );
    
CREATE TABLE tbl_passes (
    summary_id          integer PRIMARY KEY,
    lineup_id           integer REFERENCES tbl_lineups,
    total_success       integer DEFAULT 0 CHECK (total_success >= 0),
    total_failure       integer DEFAULT 0 CHECK (total_failure >= 0),
    total_no_cc_success integer DEFAULT 0 CHECK (total_no_cc_success >= 0),
    total_no_cc_failure integer DEFAULT 0 CHECK (total_no_cc_failure >= 0),
    longball_success    integer DEFAULT 0 CHECK (longball_success >= 0),
    longball_failure    integer DEFAULT 0 CHECK (longball_failure >= 0),
    layoffs_success     integer DEFAULT 0 CHECK (layoffs_success >= 0),
    layoffs_failure     integer DEFAULT 0 CHECK (layoffs_failure >= 0),
    throughballs        integer DEFAULT 0 CHECK (throughballs >= 0)
    keypasses           integer DEFAULT 0 CHECK (keypasses >= 0),
    );

CREATE TABLE tbl_passdirections (
    summary_id      integer PRIMARY KEY,
    lineup_id       integer REFERENCES tbl_lineups,
    pass_forward    integer DEFAULT 0 CHECK (pass_forward >= 0),
    pass_backward   integer DEFAULT 0 CHECK (pass_backward >= 0),
    pass_left       integer DEFAULT 0 CHECK (pass_left >= 0),
    pass_right      integer DEFAULT 0 CHECK (pass_right >= 0)
    );

CREATE TABLE tbl_passlengths (
    summary_id      integer PRIMARY KEY,
    lineup_id       integer REFERENCES tbl_lineups,
    short_success   integer DEFAULT 0 CHECK (short_success >= 0),
    short_failure   integer DEFAULT 0 CHECK (short_failure >= 0),
    long_success    integer DEFAULT 0 CHECK (long_success >= 0),
    long_failure    integer DEFAULT 0 CHECK (long_failure >= 0),
    flickon_success integer DEFAULT 0 CHECK (flickon_success >= 0),
    flickon_failure integer DEFAULT 0 CHECK (flickon_failure >= 0)
    );

CREATE TABLE tbl_passlocations (
    summary_id       integer PRIMARY KEY,
    lineup_id        integer REFERENCES tbl_lineups,
    ownhalf_success  integer DEFAULT 0 CHECK (ownhalf_success >= 0),
    ownhalf_failure  integer DEFAULT 0 CHECK (ownhalf_failure >= 0),
    opphalf_success  integer DEFAULT 0 CHECK (opphalf_success >= 0),
    opphalf_failure  integer DEFAULT 0 CHECK (opphalf_failure >= 0),
    defthird_success integer DEFAULT 0 CHECK (defthird_success >= 0),
    defthird_failure integer DEFAULT 0 CHECK (defthird_failure >= 0),
    midthird_success integer DEFAULT 0 CHECK (midthird_success >= 0),
    midthird_failure integer DEFAULT 0 CHECK (midthird_failure >= 0),
    finthird_success integer DEFAULT 0 CHECK (finthird_success >= 0),
    finthird_failure integer DEFAULT 0 CHECK (finthird_failure >= 0)
    );

CREATE TABLE tbl_penaltyactions (
    summary_id  integer PRIMARY KEY,
    lineup_id   integer REFERENCES tbl_lineups,
    taken       integer DEFAULT 0 CHECK (taken >= 0),
    saved       integer DEFAULT 0 CHECK (saved >= 0),
    offtarget   integer DEFAULT 0 CHECK (offtarget >= 0),
    ontarget    integer DEFAULT 0 CHECK (ontarget >= 0)
    );

CREATE TABLE tbl_shotbodyparts (
    summary_id      integer PRIMARY KEY,
    lineup_id       integer REFERENCES tbl_lineups,
    head_ontarget   integer DEFAULT 0 CHECK (head_ontarget >= 0),
    head_offtarget  integer DEFAULT 0 CHECK (head_offtarget >= 0),
    left_ontarget   integer DEFAULT 0 CHECK (left_ontarget >= 0),
    left_offtarget  integer DEFAULT 0 CHECK (left_offtarget >= 0),
    right_ontarget  integer DEFAULT 0 CHECK (right_ontarget >= 0),   
    right_offtarget integer DEFAULT 0 CHECK (right_offtarget >= 0)    
    );

CREATE TABLE tbl_shotblocks (
    summary_id  integer PRIMARY KEY,
    lineup_id   integer REFERENCES tbl_lineups,
    insidebox   integer DEFAULT 0 CHECK (insidebox >= 0),
    outsidebox  integer DEFAULT 0 CHECK (outsidebox >= 0),
    headed      integer DEFAULT 0 CHECK (headed >= 0),
    leftfoot    integer DEFAULT 0 CHECK (leftfoot >= 0),
    rightfoot   integer DEFAULT 0 CHECK (rightfoot >= 0),    
    other       integer DEFAULT 0 CHECK (other >= 0),    
    total       integer DEFAULT 0 CHECK (total >= 0)   
    );
    
CREATE TABLE tbl_goallineclearances (
    summary_id  integer PRIMARY KEY,
    lineup_id   integer REFERENCES tbl_lineups,
    insidebox   integer DEFAULT 0 CHECK (insidebox >= 0),
    outsidebox  integer DEFAULT 0 CHECK (outsidebox >= 0),
    totalshots  integer DEFAULT 0 CHECK (totalshots >= 0)
    );
    
CREATE TABLE tbl_shotlocations (
    summary_id           integer PRIMARY KEY,
    lineup_id            integer REFERENCES tbl_lineups,
    insidebox_ontarget   integer DEFAULT 0 CHECK (insidebox_ontarget >= 0),
    insidebox_offtarget  integer DEFAULT 0 CHECK (insidebox_offtarget >= 0),
    outsidebox_ontarget  integer DEFAULT 0 CHECK (outsidebox_ontarget >= 0),
    outsidebox_offtarget integer DEFAULT 0 CHECK (outsidebox_offtarget >= 0)
    );

CREATE TABLE tbl_shottotals (
    summary_id  integer PRIMARY KEY,
    lineup_id   integer REFERENCES tbl_lineups,
    ontarget    integer DEFAULT 0 CHECK (ontarget >= 0),
    offtarget   integer DEFAULT 0 CHECK (offtarget >= 0),
    bigchances  integer DEFAULT 0 CHECK (bigchances >= 0)  
    );

CREATE TABLE tbl_shotplays (
    summary_id          integer PRIMARY KEY,
    lineup_id           integer REFERENCES tbl_lineups,
    openplay_ontarget   integer DEFAULT 0 CHECK (openplay_ontarget >= 0),
    openplay_offtarget  integer DEFAULT 0 CHECK (openplay_offtarget >= 0),
    setplay_ontarget    integer DEFAULT 0 CHECK (setplay_ontarget >= 0),
    setplay_offtarget   integer DEFAULT 0 CHECK (setplay_offtarget >= 0),
    freekick_ontarget   integer DEFAULT 0 CHECK (freekick_ontarget >= 0),
    freekick_offtarget  integer DEFAULT 0 CHECK (freekick_offtarget >= 0),
    corners_ontarget    integer DEFAULT 0 CHECK (corners_ontarget >= 0),
    corners_offtarget   integer DEFAULT 0 CHECK (corners_offtarget >= 0),
    throwins_ontarget   integer DEFAULT 0 CHECK (throwins_ontarget >= 0),
    throwins_offtarget  integer DEFAULT 0 CHECK (throwins_offtarget >= 0),
    other_ontarget      integer DEFAULT 0 CHECK (other_ontarget >= 0),
    other_offtarget     integer DEFAULT 0 CHECK (other_offtarget >= 0)
    );
    
CREATE TABLE tbl_tackles (
    summary_id  integer PRIMARY KEY,
    lineup_id   integer REFERENCES tbl_lineups,
    won    integer DEFAULT 0 CHECK (won >= 0),
    lost   integer DEFAULT 0 CHECK (lost >= 0),
    lastman  integer DEFAULT 0 CHECK (lastman >= 0)  
    );
    
CREATE TABLE tbl_throwins (
    summary_id  integer PRIMARY KEY,
    lineup_id   integer REFERENCES tbl_lineups,
    teamplayer  integer DEFAULT 0 CHECK (teamplayer >= 0),
    oppplayer   integer DEFAULT 0 CHECK (oppplayer >= 0)
    );

CREATE TABLE tbl_touches (
    summary_id  integer PRIMARY KEY,
    lineup_id   integer REFERENCES tbl_lineups,
    dribble_overruns   integer DEFAULT 0 CHECK (dribble_overruns >= 0),
    dribble_success   integer DEFAULT 0 CHECK (dribble_success >= 0),
    dribble_failure   integer DEFAULT 0 CHECK (dribble_failure >= 0),
    balltouch_success   integer DEFAULT 0 CHECK (balltouch_success >= 0),
    balltouch_failure   integer DEFAULT 0 CHECK (balltouch_failure >= 0),
    possession_loss integer DEFAULT 0 CHECK (possession_loss >= 0),
    total  integer DEFAULT 0 CHECK (total >= 0)
    );

CREATE TABLE tbl_touchlocations (
    summary_id  integer PRIMARY KEY,
    lineup_id   integer REFERENCES tbl_lineups,
    finalthird  integer DEFAULT 0 CHECK (finalthird >= 0),
    oppbox      integer DEFAULT 0 CHECK (oppbox >= 0),
    oppsix      integer DEFAULT 0 CHECK (oppsix >= 0)
    );

