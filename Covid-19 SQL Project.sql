use [Covid 19 DB]
--select * from CovidDeaths

--select * from CovidVaccinations


select location , date , total_cases , new_cases ,total_deaths , population
from CovidDeaths

-- Looking at total cases vs total deaths

select location , 
date ,
total_cases,total_deaths, 
Round((total_deaths/total_cases)* 100,2) as Death_Percentage
from CovidDeaths
where  location like '%state%' or location = 'Pakistan'
and date >' 2022-01-01'


select Location , SUM(total_cases) 'Total Cases', 
SUM(total_deaths) 'Total Deaths' , 
Round((SUM(total_deaths)/SUM(total_cases))*100 ,2) as Death_Percentage
from CovidDeaths
where location like '%states%'
group by location;

--Looking at total cases vs Population

select location , date , total_cases, population, Round((total_cases/population)*100 ,2) as cases_percentage 
from CovidDeaths
where location like '%states%'

--Looking at countries with highest infection rate compared to Population

select  location, population, MAX(total_cases) 'Highest infection Count' ,
Round(MAX((total_cases/population))*100 ,2) "Percentage of Population infected"
from CovidDeaths
Group by location , population
order by [Percentage of Population infected] desc

-- Countries with highest Deaths count per Cases

SELECT 
  location,
  population,
  MAX(total_cases) "Highest Cases count",
  MAX(total_deaths) "Highest Deaths Count",
  ROUND(MAX(total_deaths)/MAX(total_cases)*100,2)"Highest Death % per cases"

from  
   CovidDeaths
where continent is not null
Group BY 
   location , population
Order BY 
   [Highest Death % per cases] desc


-- Countries with Highest Deaths % over Population
SELECT 
    location, 
    population,  
    MAX(total_deaths) AS "Highest Death Count", 
    ROUND((MAX(total_deaths) / population) * 100, 2) AS "Highest deaths % over Population"
FROM 
    CovidDeaths
where continent is not null
GROUP BY 
    location, population
ORDER BY 
    "Highest deaths % over Population" DESC;



--select * from 
--CovidDeaths
--where continent is null
 

 -- Countries with Maximum deaths

 select location , MAX(total_deaths) "Total Deaths"
 from CovidDeaths
 where continent is not null 
 Group BY location
 order by [Total Deaths] desc

-- Continent

select continent , MAX(total_deaths) "Total Deaths"
from CovidDeaths
where continent is not null
Group by continent
order by continent desc


select continent , total_deaths "Total Deaths"
from CovidDeaths
where continent is not null
Group by continent,total_deaths
order by continent desc

--Continents with Highest Deaths % over Population

SELECT 
continent, MAX(population) as population, MAX(total_deaths) AS max_total_deaths,  
ROUND((MAX(total_deaths) /MAX( population)) * 100,2) AS "Death % over Population"
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY "Death % over Population" DESC;

SELECT 
continent, SUM(population) as population, SUM(total_deaths) AS max_total_deaths,  
ROUND((SUM(total_deaths) /SUM( population)) * 100,2) AS "Death % over Population"
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY "Death % over Population" DESC;

--Global Figure 
-- Death % over Total cases
Select SUM(population) "Total Population",SUM(total_cases) "Total Cases",SUM(total_deaths)  "Total Deaths",
(sum(total_deaths)/SUM(total_cases))*100 "Death % over Cases"
from CovidDeaths

-- Cases % over Population
Select SUM(population) "Total Population", SUM(total_cases) "Total Cases" , SUM(total_deaths) "Total Deaths",
ROUND((SUM(total_cases)/SUM(population))*100 ,2) "Cases % Over Population"
from CovidDeaths

-- Deaths % over Population
Select SUM(population)"Total Population",SUM(total_cases) "Total Cases", SUM(total_deaths) "Total Deaths",
(SUM(total_deaths)/SUM(population)) *100 "Daeth % over Population"
FROM CovidDeaths

-- New Deaths and cases
Select SUM(new_cases) "Total Cases", SUM(new_deaths) "Total Deaths",
SUM(new_deaths )/SUM(new_cases) *100 "Death %"
FROM CovidDeaths


SELECT 
    SUM(new_cases) AS "Total Cases", 
    SUM(new_deaths) AS "Total Deaths",
    (CAST(SUM(new_deaths) AS DECIMAL(18,2)) / CAST(SUM(new_cases) AS DECIMAL(18,2))) * 100 AS "Death %"
FROM 
    CovidDeaths;


select * from CovidVaccinations





with PopvsVac (Continent, Location ,Date,Population ,New_Vaccination,"Total Amount of Vaccination")
as
(
Select dea.continent , dea.location,dea.date , dea.population ,
vac.new_vaccinations ,
SUM(Convert(bigint , vac.new_vaccinations )) OVER (Partition by dea.location Order by dea.location,dea.date)
"Total Amount of Vaccination"

from CovidDeaths dea
JOIN  CovidVaccinations vac
   ON dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
select *,
from PopvsVac


-- Use CTE

with PopvsVac (Continent, Location ,Date,Population ,New_Vaccination,"Total Amount of Vaccination")
as
(
Select dea.continent , dea.location,dea.date , dea.population ,
vac.new_vaccinations ,
SUM(Convert(bigint , vac.new_vaccinations )) OVER (Partition by dea.location Order by dea.location,dea.date)
"Total Amount of Vaccination"

from CovidDeaths dea
JOIN  CovidVaccinations vac
   ON dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
select *,Round(("Total Amount of Vaccination"/Population)*100 , 2)
from PopvsVac


-- TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent  nvarchar(300),
Location nvarchar(300),
Date datetime,
Population numeric,
New_Vaccinations numeric,
"Total Amount of Vaccination" numeric
)
INSERT into #PercentPopulationVaccinated
select dea.continent, dea.location , dea.date,dea.population , Vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location ,dea.date)
"Total Amount of Vaccination"
from CovidDeaths dea
Join CovidVaccinations vac
ON dea.date = vac.date
and dea.continent = vac.continent
where dea.continent is not null
select *,Round(("Total Amount of Vaccination"/Population)*100 , 2)
from #PercentPopulationVaccinated


-- Creating View to store Data for Visualizations

Create View PercentPopulationVaccinated as
Select dea.continent , dea.location,dea.date , dea.population ,
vac.new_vaccinations ,
SUM(Convert(bigint , vac.new_vaccinations )) OVER (Partition by dea.location Order by dea.location,dea.date)
"Total Amount of Vaccination"

from CovidDeaths dea
JOIN  CovidVaccinations vac
   ON dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3