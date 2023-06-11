-==============================================================================================
--Total wins for every engine

SELECT 
	t.engine AS engine_name,
	COUNT(t.engine) AS engine_wins
FROM Formula1.dbo.Formula1_Teams t
GROUP BY t.engine
ORDER BY engine_wins DESC;

--================================================================================
--Total wins of each team 

SELECT 
	t.team AS team_name,
	COUNT(t.team) AS team_wins
FROM Formula1.dbo.Formula1_Teams t
GROUP BY t.team
ORDER BY team_wins DESC;

--How many times each driver has become a champion
SELECT 
	d.driver_champ,
	COUNT(d.driver_champ) AS Champion
FROM Formula1.dbo.Formula1_Drivers d
GROUP BY d.driver_champ
ORDER BY Champion DESC;
--==============================================================================================
--Breaking down the Pole Positions per each driver 

SELECT 
	pl.pole_positions AS Driver,
	COUNT(pl.pole_positions) AS TotalPolPos
FROM Formula1.dbo.Formula1_pole_laps pl
GROUP BY pl.pole_positions
ORDER BY TotalPolPos DESC;

--====================================================================================================
--Breaking down the fastest laps per each driver (Displaying the top 22)

SELECT TOP 22
	fl.fastest_laps AS Driver,
	COUNT(fl.fastest_laps) AS TotalFasLaps
FROM Formula1.dbo.Formula1_pole_laps fl
GROUP BY 
	fl.fastest_laps
ORDER BY 
	TotalFasLaps DESC;

--============================================================================
--Looking at the owner's fastest laps and owners pole positions

SELECT 
	fl.grand_prix, 
	fl.date, 
	fl.circuit, 
	fl.fastest_laps AS OwnerFasLap, 
	pl.pole_positions AS OwnerPolPos
FROM Formula1.dbo.Formula1_pole_laps fl
	LEFT JOIN Formula1.dbo.Formula1_pole_laps pl ON fl.grand_prix = pl.grand_prix AND fl.date = pl.date
WHERE YEAR(fl.date) = 2021
ORDER BY date ASC;

--==============================================================================
--Looking at all the champions, owner's fastest laps and pole positions
SELECT 
	fl.grand_prix, 
	fl.date, fl.circuit, 
	d.driver_champ AS Champion,
	fl.fastest_laps AS OwnerFasLap, 
	pl.pole_positions AS OwnerPolPos
FROM Formula1.dbo.Formula1_pole_laps fl
	LEFT JOIN Formula1.dbo.Formula1_pole_laps pl ON fl.grand_prix = pl.grand_prix AND fl.date = pl.date
	LEFT JOIN Formula1.dbo.Formula1_Drivers d ON d.grand_prix = fl.grand_prix AND fl.date = d.date
WHERE YEAR(fl.date) = 2021
ORDER BY date ASC;

-- 
/* 
	Looking at all the champions, owner's fastest laps, 
	pole positions, their teams and engines used in the year of 2021
*/
SELECT 
    f1.grand_prix, 
	f1.date, f1.circuit, 
	f1.Champion,
	f1.OwnerFasLap, 
	f1.OwnerPolPos,
	f1.team,
	f1.engine
FROM 
(SELECT 
	fl.grand_prix, 
	fl.date, fl.circuit, 
	d.driver_champ AS Champion,
	fl.fastest_laps AS OwnerFasLap, 
	pl.pole_positions AS OwnerPolPos,
	t.team,
	t.engine
FROM Formula1.dbo.Formula1_pole_laps fl
	LEFT JOIN Formula1.dbo.Formula1_pole_laps pl ON fl.grand_prix = pl.grand_prix AND fl.date = pl.date
	LEFT JOIN Formula1.dbo.Formula1_Drivers d ON d.grand_prix = fl.grand_prix AND fl.date = d.date
	LEFT JOIN Formula1.dbo.Formula1_Teams t ON t.grand_prix = pl.grand_prix AND t.date =pl.date
GROUP BY fl.grand_prix, 
	fl.date, fl.circuit, 
	d.driver_champ, fl.fastest_laps, pl.pole_positions, t.team,
	t.engine) f1
WHERE YEAR (f1.date) = 2021
ORDER BY f1.date DESC;


--Creating a Temp Table

DROP TABLE if exists #results_2021

CREATE TABLE #results_2021 (
	grand_prix VARCHAR(100) NOT NULL,
	date DATE NOT NULL,
	circuit VARCHAR(100) NOT NULL,
	Champion VARCHAR(100) NOT NULL,
	OwnerFasLap VARCHAR(100) NOT NULL,
	OwnerPolPos VARCHAR(100) NOT NULL,
	team VARCHAR(100) NOT NULL,
	engine VARCHAR(100) NOT NULL
	)
INSERT INTO #results_2021
SELECT 
    f1.grand_prix, 
	f1.date, f1.circuit, 
	f1.Champion,
	f1.OwnerFasLap, 
	f1.OwnerPolPos,
	f1.team,
	f1.engine
FROM 
(SELECT 
	fl.grand_prix, 
	fl.date, fl.circuit, 
	d.driver_champ AS Champion,
	fl.fastest_laps AS OwnerFasLap, 
	pl.pole_positions AS OwnerPolPos,
	t.team,
	t.engine
FROM Formula1.dbo.Formula1_pole_laps fl
	LEFT JOIN Formula1.dbo.Formula1_pole_laps pl ON fl.grand_prix = pl.grand_prix AND fl.date = pl.date
	LEFT JOIN Formula1.dbo.Formula1_Drivers d ON d.grand_prix = fl.grand_prix AND fl.date = d.date
	LEFT JOIN Formula1.dbo.Formula1_Teams t ON t.grand_prix = pl.grand_prix AND t.date =pl.date
GROUP BY 
	fl.grand_prix, 
	fl.date, fl.circuit, 
	d.driver_champ, 
	fl.fastest_laps, 
	pl.pole_positions, 
	t.team,
	t.engine) f1
WHERE YEAR (f1.date) = 2021
ORDER BY f1.date DESC;

--Creating Views to store Data for later visualizations

GO
CREATE VIEW TotalTeamWins as
	SELECT 
		t.team AS team_name,
		COUNT(t.team) AS team_wins
	FROM Formula1.dbo.Formula1_Teams t
	GROUP BY t.team
	--ORDER BY team_wins DESC;
GO
--===============================
GO
CREATE VIEW TotalEngineWins as
	SELECT 
		t.engine AS engine_name,
		COUNT(t.engine) AS engine_wins
	FROM Formula1.dbo.Formula1_Teams t
	GROUP BY t.engine
	--ORDER BY engine_wins DESC;
GO
--===============================
GO
CREATE VIEW TotalDriverWins as
	SELECT 
	d.driver_champ,
	COUNT(d.driver_champ) AS Champion
	FROM Formula1.dbo.Formula1_Drivers d
	GROUP BY d.driver_champ;
--ORDER BY Champion DESC;
GO
--===============================
GO
CREATE VIEW Champs_FastLaps_PolePos as
	SELECT 
    f1.grand_prix, 
	f1.date, f1.circuit, 
	f1.Champion,
	f1.OwnerFasLap, 
	f1.OwnerPolPos,
	f1.team,
	f1.engine
FROM 
(SELECT 
	fl.grand_prix, 
	fl.date, fl.circuit, 
	d.driver_champ AS Champion,
	fl.fastest_laps AS OwnerFasLap, 
	pl.pole_positions AS OwnerPolPos,
	t.team,
	t.engine
FROM Formula1.dbo.Formula1_pole_laps fl
	LEFT JOIN Formula1.dbo.Formula1_pole_laps pl ON fl.grand_prix = pl.grand_prix AND fl.date = pl.date
	LEFT JOIN Formula1.dbo.Formula1_Drivers d ON d.grand_prix = fl.grand_prix AND fl.date = d.date
	LEFT JOIN Formula1.dbo.Formula1_Teams t ON t.grand_prix = pl.grand_prix AND t.date =pl.date
GROUP BY fl.grand_prix, 
	fl.date, fl.circuit, 
	d.driver_champ, fl.fastest_laps, pl.pole_positions, t.team,
	t.engine) f1
WHERE YEAR (f1.date) = 2021
--ORDER BY f1.date ASC;
GO
--===============================
