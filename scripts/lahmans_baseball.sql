-- 1. What range of years for baseball games played does the provided database cover?
SELECT MAX(year) - MIN(year)
FROM homegames;

--145 years. The earliest date being 1871 and the latest date being 2016

-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
SELECT *
FROM people
ORDER BY height
LIMIT 1;

SELECT *
FROM appearances
INNER JOIN people
USING(playerid)
WHERE playerid = 'gaedeed01'

SELECT teamid,
name
FROM appearances
INNER JOIN people
USING(playerid)
INNER JOIN teams
USING(teamid)
WHERE playerid = 'gaedeed01'
AND teamid = 'SLA'
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

-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

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
GROUP BY decade
ORDER BY decade

--They have risen over time for both categories.

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
WITH my_cte AS 
(SELECT yearid,
MAX(w) AS highest_win
FROM teams
WHERE yearid BETWEEN 1970 and 2016
GROUP BY yearid
ORDER BY yearid)
SELECT m.yearid,
teamid,
highest_win,
wswin
FROM teams AS t
INNER JOIN my_cte AS m
ON t.yearid = m.yearid


SELECT *
FROM teams

-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.


-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.