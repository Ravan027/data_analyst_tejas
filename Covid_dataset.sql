--Covid dths
Select *
From [Covid ]..CovidDeaths
Where continent is not null 
order by 3,4 

--Covid Vaccinations
Select *
From [Covid ]..CovidVaccinations
Where continent is not null 
order by 3,4

select location, 
       DATE, 
	   total_cases,
	   new_cases,
	   total_dths,
	   population  
From [Covid ]..CovidDeaths
Where continent is not null 
order by 1,2

--total dths vs total cases

select location, 
	   DATE, 
	   total_cases,
	   new_cases,
	   total_deaths,
	   (total_deaths/total_cases)*100 as TotalDeathPercentage
From [Covid ]..CovidDeaths 
Where continent is not null AND 
	  location like '%india%'
--where location like '%india%'
order by 1,2;

--Total cases vs Population

select location, 
	   DATE, 
	   total_cases,
	   new_cases,
	   total_deaths,
	   population,
	   (total_cases/population)*100 as TotalCasesPercentage
From [Covid ]..CovidDeaths 
Where continent is not null AND 
	  location like '%india%'
order by 1,2

--Countrys with high infection rates

SELECT
    location,
	population,
    MAX(new_cases) AS max_new_cases,
    MAX(total_deaths) AS max_total_deaths,
    MAX(total_cases) AS max_total_cases,
    MAX((total_cases / population) * 100) AS max_infection_percentage
FROM
    [Covid ]..CovidDeaths
Where continent is not null --AND 
--	  location like '%india%'
GROUP BY
    location, population
ORDER BY
    1,2;

--Death Count by population (Highest)

SELECT
    location,
	population,
	continent,
    MAX(cast(Total_deaths as int)) AS max_total_deaths
FROM
    [Covid ]..CovidDeaths
Where continent is not null --AND 
--	  location like '%india%'
GROUP BY
    location,continent, population
ORDER BY
	continent,
    max_total_deaths desc;

--  contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as max_total_deaths
From 
	[Covid ]..CovidDeaths
Where continent is not null --AND 
--	  location like '%india%'
Group by continent
order by max_total_deaths desc


-- Total Number of covid cases in world 

Select --date,
	   SUM(new_cases) as total_cases, 
	   SUM(cast(new_deaths as int)) as total_deaths, 
	   SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Covid ]..CovidDeaths
Where continent is not null --AND 
--	  location like '%india%' 
--Group By date
order by 1,2



--CovidVaccinations   

select * from [Covid ]..CovidVaccinations
Where continent is not null 
order by 3,4

-- Using joins
select * 
from [Covid ]..CovidDeaths d
join [Covid ]..CovidVaccinations v
	on d.location = v.location and
	d.date =v.date
Where d.continent is not null 
order by 2,3



select d.date , d.location, d.continent , d.population, v.new_vaccinations 
from [Covid ]..CovidDeaths d
join [Covid ]..CovidVaccinations v
	on d.location = v.location and
	d.date =v.date
Where d.continent is not null and
      v.new_vaccinations is not null
order by 2,3

-- Total Population vs Vaccinations
--  Percentage of Population that has recieved at least one Covid Vaccine

Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Covid ]..CovidDeaths d 
Join [Covid ]..CovidVaccinations v
	on d.location = v.location and
	d.date =v.date
where d.continent is not null and
	  v.new_vaccinations is not null
order by 2,3

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Covid ]..CovidDeaths d
Join [Covid ]..CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Covid ]..CovidDeaths d
Join [Covid ]..CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
--where d.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Covid ]..CovidDeaths d
Join [Covid ]..CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null 

