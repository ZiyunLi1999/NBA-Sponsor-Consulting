-- 1) Team related queries
--- A. Most popular teams
---- a. Teams with the most all-stars?
select t.team_name, count(ps.player_id) as num_all_stars
from team t
join player_stats ps on t.team_id=ps.team_id
where ps.player_id in (select p.player_id
	from player p
	right join all_star a 
	on p.player_id = a.player_id)
group by t.team_name
order by num_all_stars desc

---- b. Teams with highest win percentages
select num_games.team_id, num_games.team_name, num_games.num_games, num_wins.num_wins, round(num_wins.num_wins*100/num_games.num_games,1) as win_percentage
from (select t.team_id, t.team_name, count(g.game_id) as num_games
from team t
join team_game tg on t.team_id = tg.home_team_id or t.team_id = tg.visitor_team_id
join game g on tg.game_id = g.game_id
group by t.team_id, t.team_name
order by t.team_id) as num_games
join (select t.team_id, t.team_name, count(g.game_id) as num_wins
from team t
join team_game tg on t.team_id = tg.home_team_id or t.team_id = tg.visitor_team_id
join game g on tg.game_id = g.game_id
where g.winner_id = t.team_id
group by t.team_id, t.team_name
order by t.team_id) as num_wins on num_games.team_id = num_wins.team_id
order by win_percentage desc

---- c. Teams and arenas
----- c1. Most wins took place at each team's home game
------- percentage of wins in home vs as a visitor
select
round((select count(tg.game_id) as num
from team_game tg
join game g on tg.game_id = g.game_id
where tg.home_team_id = g.winner_id)*100/(select count(*)
from game),1) as home_wins,
round((select count(tg.game_id) as num
from team_game tg
join game g on tg.game_id = g.game_id
where tg.visitor_team_id = g.winner_id)*100/(select count(*)
from game),1) as visitor_wins

------- number of wins in home vs. as a visitor
select
(select count(tg.game_id) as num
from team_game tg
join game g on tg.game_id = g.game_id
where tg.home_team_id = g.winner_id) as home_wins,
(select count(tg.game_id) as num
from team_game tg
join game g on tg.game_id = g.game_id
where tg.visitor_team_id = g.winner_id) as visitor_wins,
(select count(*) from game) as total_games

----- c2. 5 teams with the most wins in 2020, and their arena
select r.ranking, t.team_name, a.arena_name
from ranking r
join team t on r.team_id=t.team_id
join team_arena ta on t.team_id=ta.team_id
join arena a on a.arena_id = ta.arena_id
where r.year='2020' and r.ranking<6
group by r.ranking, t.team_name, a.arena_name
order by r.ranking


--- C. Scenario based: competitor's sponsored team's competitor
------ the team that won the most against MIL - a challenger of Harley Davidson
------- players/teams sponsored by its competitor
select c.company_name, tc.year, t.team_name, t.team_id
from company c
join team_company tc on c.company_id = tc.company_id
join team t on t.team_id = tc.team_id
where c.company_name = 'Harley-Davidson'
------- count number of wins: team that beat MIL the most frequent
select g.winner_id, count(g.game_id) as num_wins
from team_game tg
join game g on tg.game_id=g.game_id
where (g.winner_id!='11' and tg.home_team_id= '11') or (g.winner_id!='11' and tg.visitor_team_id='11') 
group by g.winner_id
order by num_wins desc;
------- team name, team id match
select team_name
from team
where team_id = '23'

-- 2）Player related queries
--- A. Most popular players
---- a. players with most points_scored in all games they played
select p.player_name, pg.player_id, sum(pg.points_scored) as total_points_scored
from player p
join player_game pg on p.player_id = pg.player_id
group by p.player_name, pg.player_id
order by total_points_scored desc
---- b. players with most points_scored per game
select p.player_name, pg.player_id, round(sum(pg.points_scored)/count(pg.game_id),2) as points_scored_per_game
from player p
join player_game pg on p.player_id = pg.player_id
group by p.player_name, pg.player_id
order by points_scored_per_game desc
limit 25
---- B. Gaterade sponsor based on player characteristics (2020)
----- a. top 10 players most active in offense
select p.player_name, ps.player_id, ps.mpg, ps.min_percentage, ps.usage_percentage
from player_stats ps
join player p on ps.player_id = p.player_id
where ps.year='2020'
order by mpg desc, min_percentage desc, usage_percentage desc
limit 10;
----- b. top 10 players most alert
select p.player_name, ps.player_id, ps.turnover_percentage, ps.steal_per_game
from player_stats ps
join player p on ps.player_id = p.player_id
where ps.year='2020'
order by turnover_percentage asc, steal_per_game desc
limit 10;
----- c. top 10 players best concentration
select p.player_name, ps.player_id, ps.freethrow_percentage, ps.two_point_percentage, ps.three_point_percentage
from player_stats ps
join player p on ps.player_id = p.player_id
where ps.year='2020'
order by freethrow_percentage desc, two_point_percentage desc, three_point_percentage desc
limit 10;


















