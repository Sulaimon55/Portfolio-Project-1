SELECT *
FROM CovidDeaths
ORDER BY 3,4


--SELECT *
--FROM CovidVaccinations$
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2


---Looking at Total Cases vs Total Deaths
---Likelihood of death from Covid

SELECT location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / CONVERT(float, total_cases)*100) AS DeathPercent
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

----Alternatively, we can write the above query as below:
SELECT location, date, total_cases, total_deaths,CAST(total_deaths as int) / CAST(total_deaths as int)
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2



---Looking at Total Cases vs Population
---Shows what percentage of population got covid

SELECT location, date, population, total_cases,(CONVERT(float, total_cases) / NULLIF (CONVERT(float, population),0)*100) AS InfectionPercentage
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

SELECT location, date, population, total_cases,(CONVERT(float, total_cases) / NULLIF (CONVERT(float, population),0)*100) AS InfectionPercentage
FROM CovidDeaths
ORDER BY 1,2

---Which country has highest infection rate

SELECT location, population,MAX(CAST(total_cases as int)) AS HighestInfectionRate,MAX((CAST(total_cases as int)) / population)*100 AS InfectionPercentage
FROM CovidDeaths
GROUP BY location, population
ORDER BY InfectionPercentage DESC


SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathsCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathsCount DESC

--SHOWING THE CONTINENTS WITH HIGHEST RATE OF INFECTION
SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathsCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathsCount DESC


SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathsCount
FROM CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathsCount DESC

---gLOBAL nUMBERS
SELECT date,sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,sum(new_deaths)/sum(new_cases)*100
FROM CovidDeaths
where continent is not null
group by date
order by 1,2

SELECT sum(new_cases), Sum(cast(new_deaths as int)),Sum(convert(float,new_deaths))/sum(nullif (convert(float,new_cases),0))*100 as PercentageOfNewDeath
FROM CovidDeaths
where continent is not null
--group by date
order by 1,2

SELECT sum(new_cases), Sum(cast(new_deaths as int)),Sum(cast(new_deaths as int))/sum(new_cases)*100 as PercentageOfNewDeath
FROM CovidDeaths
where continent is not null
--group by date
order by 1,2


--we move to vaccination tBLE

SELECT* 
FROM CovidVaccinations$ dea

SELECT* 
FROM CovidDeaths dea
join CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM CovidDeaths dea
join CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(float,vac.new_vaccinations )) OVER (partition by dea.location order by dea.location, dea.date)as CummulativeVaccination
FROM CovidDeaths dea
join CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

---To query Vaccination vs Population
--USE CTE
With PopvsVac (continent, location, date, population, new_vaccination,cummulative_vaccination)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date)as CummulativeVaccination
FROM CovidDeaths dea
join CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
---order by 2,3
)
select*,(cummulative_vaccination/population)*100 as PopPercentageVaccinated
from PopvsVac


--Another Version
With PopvsVac (continent, location, date, population, new_vaccination,cummulative_vaccination)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(float,vac.new_vaccinations )) OVER (partition by dea.location order by dea.location, dea.date)as CummulativeVaccination
FROM CovidDeaths dea
join CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select*,(cummulative_vaccination/population)*100 as PopPercentageVaccinated
from PopvsVac

---OTHER QUERIES
---LET'S INTRODUCE A TEMP TABLE
DROP Table if exists #PopPercentageVaccinated
Create Table #PopPercentageVaccinated 
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
CummulativeVaccination numeric
)

insert into #PopPercentageVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date)as CummulativeVaccination
FROM CovidDeaths dea
join CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
---order by 2,3

select *
from #PopPercentageVaccinated



insert into #PopPercentageVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(float,vac.new_vaccinations )) OVER (partition by dea.location order by dea.location, dea.date)as CummulativeVaccination
FROM CovidDeaths dea
join CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3


---Creating view to store data for later visualization
create view PopPercentageVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date)as CummulativeVaccination
FROM CovidDeaths dea
join CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
---order by 2,3


select *
from PopPercentageVaccinated