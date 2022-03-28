SELECT * FROM PortfolioProject..CovidDeaths$
WHERE continent!=''
ORDER BY 3,4

--SELECT * FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3,4

--Seleccionar data que iremos a usar

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths$
ORDER BY 1,2

--Veremos el total de casos vs el total de muertes
--Muestra la probabilidad de muertes 
SELECT location,date,total_cases,total_deaths,total_porcentage_deaths=(total_deaths/total_cases)*100
FROM CovidDeaths$
WHERE location like '%states%'
ORDER BY 1,2

--cuantos casos respecto a la poblacion
SELECT location,date,total_cases,population,casesPorcentage=(total_cases/population)*100
FROM CovidDeaths$
WHERE location like '%states%'
ORDER BY 1,2

SELECT location,date,total_cases,population,casesPorcentage=(total_cases/population)*100
FROM CovidDeaths$
--WHERE location like '%states%'
ORDER BY 1,2

--Cual es el pais con mayor ratio de contagiados respecto a la poblacion
SELECT location,MAX(total_cases) as HighestInfectionCount,population,MaxcasesPorcentage=MAX((total_cases/population))*100
FROM CovidDeaths$
--WHERE location like '%states%'
GROUP BY location,population
ORDER BY MaxcasesPorcentage DESC

--Mostramos los paises en donde se tuvo mayor cantidad de muertes por poblacion
SELECT location,MAX(cast(total_deaths as int)) as HighestDeathsCount
FROM PortfolioProject..CovidDeaths$
WHERE continent !=''
--WHERE location like '%states%'
GROUP BY location
ORDER BY HighestDeathsCount DESC

--Veamos lo mismo anterior pero por continentes
SELECT continent,MAX(cast(total_deaths as int)) as HighestDeathsCount
FROM PortfolioProject..CovidDeaths$
WHERE continent !=''
--WHERE location like '%states%'
GROUP BY continent
ORDER BY HighestDeathsCount DESC

--Vemos los continentes con la mayor cantidad de muertes por poblacion

SELECT  SUM(new_cases) as sum_new_cases, SUM(CAST(new_deaths as int)) as sum_new_deaths, (SUM(CAST(new_deaths as INT))/SUM(new_cases))*100 as DeathPorcentage
FROM CovidDeaths$
WHERE continent !=''
--GROUP BY date
ORDER BY 1,2


WITH PopulationvsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as(
SELECT DEATH.continent, DEATH.location,DEATH.date,DEATH.population,VAC.new_vaccinations,
SUM(CAST(VAC.new_vaccinations as float)) OVER (Partition by DEATH.location ORDER BY DEATH.location,DEATH.date) as RollingPeopleVaccinated
FROM CovidDeaths$ DEATH
JOIN CovidVaccinations$ VAC
	ON DEATH.location=VAC.location
	AND DEATH.date=VAC.date
WHERE DEATH.continent !=''
--ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/population)*100
FROM PopulationvsVac


--Tabla temporal

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT DEATH.continent, DEATH.location,DEATH.date,DEATH.population,VAC.new_vaccinations,
SUM(CAST(VAC.new_vaccinations as float)) OVER (Partition by DEATH.location ORDER BY DEATH.location,DEATH.date) as RollingPeopleVaccinated
FROM CovidDeaths$ DEATH
JOIN CovidVaccinations$ VAC
	ON DEATH.location=VAC.location
	AND DEATH.date=VAC.date

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

--Creando vista para almacenar data para posteriores visualizaciones

CREATE VIEW Percent_PopulationVaccinated as
SELECT DEATH.continent, DEATH.location,DEATH.date,DEATH.population,VAC.new_vaccinations,
SUM(CAST(VAC.new_vaccinations as float)) OVER (Partition by DEATH.location ORDER BY DEATH.location,DEATH.date) as RollingPeopleVaccinated
FROM CovidDeaths$ DEATH
JOIN CovidVaccinations$ VAC
	ON DEATH.location=VAC.location
	AND DEATH.date=VAC.date
WHERE DEATH.continent !=''
--ORDER BY 2,3

SELECT *
FROM Percent_PopulationVaccinated