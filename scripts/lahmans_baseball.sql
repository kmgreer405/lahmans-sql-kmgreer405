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

SELECT LEFT(CAST(p.yearid AS varchar), 3) AS decade,
ROUND(AVG(p.so/p.g)*10,2) AS so_per_game
FROM pitching AS p
WHERE CAST(LEFT(CAST(p.yearid AS varchar), 3) AS int) >= 192
GROUP BY decade
ORDER BY decade

SELECT LEFT(CAST(yearid AS varchar), 3) AS decade,
ROUND(AVG(hr/g)*10,2) AS hr_per_game
FROM batting AS b
WHERE CAST(LEFT(CAST(yearid AS varchar), 3) AS int) >= 192
GROUP BY decade
ORDER BY decade

--The strikeouts have gone up since the 1920's peaking around 16.2 in the 1960's a game. homeruns have always been below two decimal places per game.

-- 6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.

SELECT DISTINCT playerid AS player,
sb 
FROM batting
WHERE yearid = 2016
AND sb + cs >= 20


--I don't know why this isn't working

-- 7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?
SELECT teamid,
w
FROM teams
WHERE yearid BETWEEN 1970 and 2016
ORDER BY w DESC

SELECT *
FROM seriespost
-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.


-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.