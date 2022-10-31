Select * From PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3,4;

--Select * From PortfolioProject.dbo.CovidVaccinations
--order by 3,4;

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases,total_deaths, population
From PortfolioProject.dbo.CovidDeaths
order by 1,2;

--total cases vs. total deaths
--shows the % of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
where location like '%states%'
order by 1,2;

--total cases vs population
--shows % of population that contracted covid in your country
Select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
where location like '%states%'
order by 1,2;

-- countries with highest infection rate compared to population
Select location, population, Max(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
group by location,population
order by PercentPopulationInfected desc;


-- Countries with the highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc;

--BREAKING THINGS DOWN BY CONTINENT

--continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc;


--GLOBAL NUMBERS

Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2;

--without DATE
Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2;

-- total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) as RollingCountOfPeopleVaxed
--, (RollingCountOfPeopleVaxed/population)
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;

--use CTE
with PopsvsVac(continent, location, date, population,new_vaccinations, RollingCountOfPeopleVaxed)
as(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) as RollingCountOfPeopleVaxed
--, (RollingCountOfPeopleVaxed/population)
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingCountOfPeopleVaxed/population)*100
from PopsvsVac


--use TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated --'Drop Table if exists' is useful if you are wanting to make changes to the temp table
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingCountOfPeopleVaxed numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) as RollingCountOfPeopleVaxed
--, (RollingCountOfPeopleVaxed/population)
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingCountOfPeopleVaxed/population)*100
from #PercentPopulationVaccinated;

-- Creating VIEW to store data for later visualizations
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) as RollingCountOfPeopleVaxed
--, (RollingCountOfPeopleVaxed/population)
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
;

select * from PercentPopulationVaccinated; -- table created from view above