--select *
--from PortfolioProject..covidDeaths
--order by 3,4

--select *
--from PortfolioProject..covidVaccinations
--order by 3,4

--Select data to use

--select location, date, total_cases, new_cases, total_deaths, population
--from PortfolioProject..covidDeaths
--order by 1,2

-- Look at total cases v. total deaths
-- Shows liklihood of dying if you contract covid in your country 
select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,4) as DeathPercent
from PortfolioProject..covidDeaths
where location like '%states'
order by 1,2

-- Look at total cases v. population
-- Percent of pop that has contracted covid
select location, date, population, total_cases, round((total_cases/population)*100,4) as InfectionPercent
from PortfolioProject..covidDeaths
--where location like '%states'
order by 1,2

-- Look at highest infection rate v. population
select location, population, max(total_cases) as highestInfectionCount, round((max(total_cases/population))*100,4) as InfectionPercent
from PortfolioProject..covidDeaths
--where location like '%states'
group by population,location
order by InfectionPercent desc


-- Shows countries with highest death count
select continent, location, max(cast(total_deaths as int)) as totalDeathCount
from PortfolioProject..covidDeaths
where continent is not null
group by continent, location
order by totalDeathCount desc

--by continent

select continent, max(cast(total_deaths as int)) as totalDeathCount
from PortfolioProject..covidDeaths
where continent is not null
group by continent
order by totalDeathCount desc

----Complete Numbers
select location, max(cast(total_deaths as int)) as totalDeathCount
from PortfolioProject..covidDeaths
where continent is null and (location not like '%income')
group by location
order by totalDeathCount desc

-- Continents w/highest death count per population
select continent, max(cast(total_deaths as int)) as totalDeathCountPercent
from PortfolioProject..covidDeaths
where continent is not null
group by continent
order by totalDeathCountPercent desc

--Global numbers
select sum(new_cases) as totalCases, sum(cast(new_deaths as float)) as totalDeaths, sum(cast(new_deaths as float))/sum(new_cases)*100 as DeathPercent
from PortfolioProject..covidDeaths
where continent is not null
order by DeathPercent desc

-- Total population v. vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RunningTotalVaccinations
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--CTE
with PopVsVac (Continent, location, date, population, new_vaccinations, RunningTotalVaccination)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RunningTotalVaccinations
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, round((RunningTotalVaccination/population)*100,4)
from PopVsVac

--Temp Table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RunningTotalVaccinations numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
	dea.date) as RunningTotalVaccinations
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, round((RunningTotalVaccinations/population) * 100,4) as PercentVaccinated
from #PercentPopulationVaccinated


-- Create view to store data for visualizations
create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
	dea.date) as RunningTotalVaccinations
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


----Total death count Per Continent
create view TotalDeathCountPerContinent as
select location, max(cast(total_deaths as int)) as totalDeathCount
from PortfolioProject..covidDeaths
where continent is null and (location not like '%income')
group by location

----Global Overview
create view GlobalOverview as 
select sum(new_cases) as totalCases, sum(cast(new_deaths as float)) as totalDeaths, sum(cast(new_deaths as float))/sum(new_cases)*100 as DeathPercent
from PortfolioProject..covidDeaths
where continent is not null

----Death Count by Country
create view DeathCountByCountry as 
select continent, location, max(cast(total_deaths as int)) as totalDeathCount
from PortfolioProject..covidDeaths
where continent is not null
group by continent, location
