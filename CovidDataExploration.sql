SELECT * FROM CovidDeathData


SELECT * FROM CovidVacinationData


UPDATE CovidVacinationData
SET new_vaccinations = NULL
WHERE new_vaccinations IN ('',' ')

--SELECTING WE NEED TO USE

SELECT location, date, total_cases, new_cases, total_deaths,population
FROM CovidDeathData
ORDER BY 1,2

--TOTAL CASES VS TOTAL DEATH
--shows percentage of death
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 AS death_percentage
FROM CovidDeathData
--WHERE location = 'India'
ORDER BY 1,2

--TOTAL CASES VS POPULATION
--shows percentage of people got covid
SELECT location, date, population, total_cases, (total_cases/population) * 100  AS case_percentage
FROM CovidDeathData
--WHERE location = 'India'
ORDER BY 1,2

--looking for country with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS Highest_Infection_count, (MAX(total_cases)/population) * 100  AS infection_rate_percentage
FROM CovidDeathData
--WHERE location = 'india'
GROUP BY location, population
ORDER BY infection_rate_percentage desc

--countries with highest death count

SELECT location, MAX(total_deaths) AS Death_count
FROM CovidDeathData
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Death_count desc

--continent with highest death count

SELECT continent, MAX(total_deaths) AS Death_count_Continent
FROM CovidDeathData
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Death_count_Continent desc

--global new cases and death by date and death persentage

SELECT date, SUM(new_cases) AS total_world_case ,SUM(new_deaths) AS total_world_death, (SUM(new_deaths)/SUM(new_cases)) * 100 AS Death_persentage
FROM CovidDeathData
WHERE continent IS NOT NULL and new_cases <> 0 
GROUP BY date
ORDER BY 1,2


-- total population, new vacination , cumilavite vacination with date and loaction

SELECT cd.continent,cd.location,cd.date,population ,cv.new_vaccinations,
	SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location order by cd.location,cd.date) AS CumilativeVaccination
FROM CovidDeathData AS cd
JOIN CovidVacinationData AS cv
ON cd.location = cv.location AND cd.date=cv.date 
WHERE cd.continent IS NOT NULL --And cd.location='cuba'
order by 2,3


--Using CTE

WITH populationVSvaccination (continent, location, date, population, new_vaccinations, CumilativeVaccination)
AS
(
SELECT cd.continent,cd.location,cd.date,population ,cv.new_vaccinations,
	SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location order by cd.location,cd.date) AS CumilativeVaccination
	FROM CovidDeathData AS cd
JOIN CovidVacinationData AS cv
	ON cd.location = cv.location AND cd.date=cv.date 
WHERE cd.continent IS NOT NULL 
--order by 2,3
)
select * , (CumilativeVaccination / population)*100 from populationVSvaccination 
--where location = 'cuba'


--temp table

DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated 
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
cumilative_vaccination numeric

)
INSERT INTO #PercentagePopulationVaccinated
SELECT cd.continent,cd.location,cd.date,population ,cv.new_vaccinations,
	SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location order by cd.location,cd.date) AS CumilativeVaccination
	FROM CovidDeathData AS cd
JOIN CovidVacinationData AS cv
	ON cd.location = cv.location AND cd.date=cv.date 
WHERE cd.continent IS NOT NULL 
--order by 2,3

select * , (cumilative_vaccination / population)*100 from #PercentagePopulationVaccinated 
--where location = 'cuba'




--creating view to store data for visualization

CREATE VIEW PercentagePopulationVaccinated 
AS
SELECT cd.continent,cd.location,cd.date,population ,cv.new_vaccinations,
	SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location order by cd.location,cd.date) AS CumilativeVaccination
	FROM CovidDeathData AS cd
JOIN CovidVacinationData AS cv
	ON cd.location = cv.location AND cd.date=cv.date 
WHERE cd.continent IS NOT NULL 
--order by 2,3

SELECT * FROM PercentagePopulationVaccinated
