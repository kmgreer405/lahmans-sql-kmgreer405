-- 1. What range of years for baseball games played does the provided database cover?

SELECT COUNT(DISTINCT year)
FROM homegames;

--146 years.

-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
SELECT namefirst,
namelast,
height,
g_all,
name
FROM people AS p
INNER JOIN appearances AS a
ON p.playerid = a.playerid
INNER JOIN teams AS t
on a.teamid = t.teamid
ORDER BY height
LIMIT 1;

--Eddie Gaedel is the shortest player at 43 inches tall. He played in 1 career game for the St. Louis Browns. 

-- 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
SELECT namefirst,
namelast,
SUM(salary) AS total_salary
FROM people
INNER JOIN salaries
USING(playerid)
WHERE playerid IN
	(SELECT DISTINCT playerid
	FROM collegeplaying
	WHERE schoolid = 'vandy')
GROUP BY namefirst, namelast
ORDER BY total_salary DESC

--David Price has made the most at $81,851,296

-- 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.
SELECT CASE WHEN pos = 'OF' THEN 'Outfield'
WHEN pos = 'P' THEN 'Battery'
WHEN pos = 'C' THEN 'Battery'
ELSE 'Infield' END AS position_group,
SUM(po)
FROM fielding
WHERE yearid = 2016
GROUP BY position_group
ORDER BY SUM(po) DESC

-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

--Have to divide games by 2 because they all play each other. 
SELECT CASE WHEN yearid BETWEEN 1920 AND 1929 THEN '1920s'
	WHEN yearid BETWEEN 1930 AND 1939 THEN '1930s'
	WHEN yearid BETWEEN 1940 AND 1949 THEN '1940s'
	WHEN yearid BETWEEN 1950 AND 1959 THEN '1950s'
	WHEN yearid BETWEEN 1960 AND 1969 THEN '1960s'
	WHEN yearid BETWEEN 1970 AND 1979 THEN '1970s'
	WHEN yearid BETWEEN 1980 AND 1989 THEN '1980s'
	WHEN yearid BETWEEN 1990 AND 1999 THEN '1990s'
	WHEN yearid BETWEEN 2000 AND 2009 THEN '2000s'
	ELSE '2010s' END AS decade,
ROUND(SUM(so) :: numeric/ SUM(g/2) :: numeric, 2) AS avg_strikeouts,
ROUND(SUM(hr) :: numeric/ SUM(g/2) :: numeric, 2) AS avg_homeruns
FROM teams
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade

--They have risen over time for both categories. outside of the 2010's but there is also four years less of data for that bracket.

-- 6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.

SELECT namefirst,
namelast,
ROUND(sb :: numeric/(sb + cs)*100,0) :: numeric AS sb_perc 
FROM batting AS b
INNER JOIN people AS p
ON b.playerid = p.playerid
WHERE yearid = 2016
AND sb + cs >= 20
ORDER BY sb_perc DESC


--Chris Owings has the highest stolen base attempt percentage at 91%

-- 7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

--Finds the pecent of teams with the most wins that also won the world series.
WITH my_cte AS ( 
SELECT yearid,
MAX(w) As max
FROM teams
WHERE yearid BETWEEN 1970 and 2016
GROUP BY yearid
ORDER BY yearid
)
SELECT ROUND((COUNT(wswin)/53 :: numeric) * 100,0) AS perc_of_top_win_winning
FROM (
SELECT m.yearid,
teamid,
wswin,
max
FROM teams AS t
INNER JOIN my_cte AS m
ON t.yearid = m.yearid
WHERE w = max
ORDER BY max DESC
) AS subquery
WHERE wswin = 'Y'


--Finds the team with the lowest wins and a world sereis win
SELECT teamid,
yearid,
MIN(w)
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
AND wswin = 'Y'
GROUP BY teamid,
yearid
ORDER BY MIN(w)


--Finds the team with the most wins and no world sereis.
WITH my_cte AS ( 
SELECT yearid,
MAX(w) As max
FROM teams
WHERE yearid BETWEEN 1970 and 2016
GROUP BY yearid
ORDER BY yearid
	)
SELECT m.yearid,
teamid,
wswin,
max
FROM teams AS t
INNER JOIN my_cte AS m
ON t.yearid = m.yearid
WHERE w = max
ORDER BY max DESC

-- LAN in 1981 had the lowest total wins while winning the world series at 63. SEA is the team that has won the most games and not won the world series at 116 in 2001. 23% of the time between 1970 and 2016 the team with he most wins also wins the world sereis.

-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

--Top 5
SELECT name,
	park_name,
h.attendance / games AS avg_attendance
FROM homegames AS h
INNER JOIN parks AS p
ON h.park = p.park
INNER JOIN teams AS t
ON h.team = t.teamid
AND h.year = t.yearid
WHERE year = 2016
AND games > 10
ORDER BY avg_attendance DESC
LIMIT 5

--Bottom 5
SELECT name,
	park_name,
h.attendance / games AS avg_attendance
FROM homegames AS h
INNER JOIN parks AS p
ON h.park = p.park
INNER JOIN teams AS t
ON h.team = t.teamid
AND h.year = t.yearid
WHERE year = 2016
AND games > 10
ORDER BY avg_attendance
LIMIT 5



-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

--not the answer. Just liked way it worked.
SELECT playerid,
awardid,
yearid,
lgid 
FROM awardsmanagers
WHERE playerid IN (
	SELECT playerid
	FROM awardsmanagers
	WHERE awardid = 'TSN Manager of the Year'
	GROUP BY playerid
	HAVING COUNT(*) > 1
	)
AND awardid = 'TSN Manager of the Year'
AND lgid <> 'ML'
ORDER BY playerid




SELECT namefirst,
	namelast,
	name
FROM awardsmanagers AS a
INNER JOIN people AS p
ON a.playerid = p.playerid
INNER JOIN managers AS m
ON a.playerid = m.playerid
AND a.yearid = m.yearid
INNER JOIN teams AS t
ON m.teamid = t.teamid
AND m.yearid = t.yearid
WHERE a.playerid IN (
	SELECT playerid 
	FROM awardsmanagers
	WHERE playerid IN (
		SELECT playerid
		FROM awardsmanagers
		WHERE lgid = 'NL'
		AND awardid = 'TSN Manager of the Year'
		)
	AND lgid = 'AL'
	AND awardid = 'TSN Manager of the Year'
	)
AND awardid = 'TSN Manager of the Year'
ORDER BY namefirst

-- Jim Leyland and Davey Johnson are the two managers to win the TSN manager of the year award in both the NL and AL.

-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.
WITH my_cte AS (
SELECT playerid,
MAX(hr) AS max_hr
FROM batting
GROUP BY playerid
HAVING MAX(hr) >= 1
)
SELECT namefirst,
namelast,
max_hr
FROM batting AS b
RIGHT JOIN my_cte AS m
ON b.playerid = m.playerid
AND b.hr = m.max_hr
INNER JOIN people AS p
ON b.playerid = p.playerid
WHERE b.yearid = 2016
AND p.debut <= '2006-12-31'
ORDER BY max_hr DESC


WITH hr_sixteen AS
(SELECT playerid, yearid, SUM(hr) as player_hr_sixteen
FROM batting
WHERE yearid = 2016
GROUP by playerid, yearid
ORDER BY player_hr_sixteen DESC),

yearly_hr AS
(SELECT playerid, yearid, SUM(hr) AS hr_yearly,
 	MAX(SUM(hr)) OVER(PARTITION BY playerid) AS best_year_hrs
FROM batting
GROUP BY playerid, yearid),

yp AS
(SELECT COUNT(DISTINCT yearid) AS years_played, playerid
FROM batting
GROUP BY playerid)

SELECT playerid, namefirst, namelast, hr_yearly AS total_hr_2016, years_played
FROM yearly_hr
INNER JOIN hr_sixteen
USING(playerid)
INNER JOIN yp
USING(playerid)
INNER JOIN people
USING(playerid)
WHERE best_year_hrs = player_hr_sixteen
	AND hr_yearly > 0
	AND yearly_hr.yearid = 2016
	AND years_played >= 10
ORDER BY total_hr_2016 DESC

-- Bonus
-- Lag / Lead
-- Lag returns the previous year's hr for that player
-- Lead returns the next year's hr for that player
SELECT yearid,
	   playerid,
	   hr,
	   LAG(hr) OVER (PARTITION BY playerid ORDER BY yearid) AS prev_yr_hr,
	   LEAD(hr) OVER (PARTITION BY playerid ORDER BY yearid) AS next_yr_hr
FROM batting
ORDER BY playerid, yearid


-- Sliding Windows
-- Same concept as with lag and lead, except new keywords allow you to do aggregations on a certain number of rows before or after
-- SUM OVER PRECEDING allows us to get the sum of the two years earlier than that row for that player
-- SUM OVER FOLLOWING allows us to get the sum of the two years after that row for that player
SELECT yearid,
	   playerid,
	   hr,
	   SUM(hr) OVER (PARTITION BY playerid 
					 ORDER BY yearid
					ROWS BETWEEN 2 PRECEDING AND 1 PRECEDING) AS prev_2yr_hr,
	   SUM(hr) OVER (PARTITION BY playerid 
					 ORDER BY yearid
					 ROWS BETWEEN 1 FOLLOWING AND 2 FOLLOWING) AS next_2yr_hr
FROM batting
ORDER BY playerid, yearid


-- GROUP BY ROLLUP
-- Same as a GROUP BY, except each group is followed by a total for that group and a grand total for multiple groups
-- The rollup means we will get a total for the sub group - so we have totals per year per team, the rollup adds the total as if we had also grouped by just year, followed by the total for the entire table

SELECT yearid,
	   teamid,
	   SUM(hr)
FROM batting
GROUP BY ROLLUP(yearid, teamid)
ORDER BY yearid, teamid


-- GROUP BY CUBE
-- Similar to ROLLUP, except instead of just giving us the totals for the larger group (which it still does at the end of each year as before), it also gives us the totals of the groups if they had been grouped the other way
-- So in this example, we get the totals by year as well as the totals by team
SELECT yearid,
	   teamid,
	   SUM(hr)
FROM batting
GROUP BY CUBE(yearid, teamid)
ORDER BY yearid, teamid


-- To make this easier to read, use coalesce to change the nulls to accurate labels
SELECT COALESCE(yearid :: text, 'All Years'),
	   COALESCE(teamid, 'All Teams'),
	   SUM(hr)
FROM batting
GROUP BY CUBE(yearid, teamid)
ORDER BY yearid, teamid



