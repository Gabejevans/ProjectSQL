select *
-- continent, location, total_cases
from PortfolioProject.dbo.CovidDeaths
order by 3,4

-- select *
-- continent, location, total_cases
-- from PortfolioProject.dbo.CovidVaccinations
-- order by 3,4

-- Select the data we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- shows the likelihood of dying if you contract covid in your country 
Select location, date, total_cases, total_deaths , round((cast(total_deaths as float))/cast(total_cases as float)*100, 2)  as death_percentage
From PortfolioProject..CovidDeaths
where location like '%united kingdom%'
order by 1,2

-- looking at total cases vs population 

Select location, date, total_cases, population, round((cast(total_cases as float))/cast(population as float)*100, 3)  as infection_rate
From PortfolioProject..CovidDeaths
where location like '%united kingdom%'
order by 1,2

-- looking at countries with highest infection rate compared to population 

Select location, population ,max(cast(total_cases as float)) as highest_infection_count
, max((cast(total_cases as float)/cast(population as float)))*100 as percentage_population_infected
from PortfolioProject..CovidDeaths

where population > 10000000
group by location, population
order by percentage_population_infected desc


-- showing the countries witht he highest death count per population

-- lets break things down by continent

-- showing continents with the highest death counts 

Select continent,  max(total_deaths) as total_death_count --, round((cast(total_deaths as float))/cast(total_cases as float)*100, 2)  as death_percentage
From PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by total_death_count desc

-- Global Numbers

Select date, sum(new_cases), sum(new_deaths), sum(new_deaths)/sum(new_cases)* 100 as death_percentage
From PortfolioProject..CovidDeaths
where continent is not null
group by date 
order by 1,2


-- looking at total population vs vaccinations 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)
as cumulative_vaccinations 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location 
	and dea.date = vac.date 

where dea.continent is not null 

-- USE CTE

with pop_vs_vac (continent, location, date, population, new_vaccinations, cumulative_vaccinations)
as 
( select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,
 dea.date) as cumulative_vaccinations

from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date 
where dea.continent is not null
--order by 2,3
)
select *, round(convert(float,cumulative_vaccinations)/convert(float,population), 4)*100
as percentage_vaccinated
from pop_vs_vac
order by 2,3

-- Temp Table
drop table if exists #percentage_population_vaccinated
create table #percentage_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date date,
population numeric,
new_vaccinations numeric,
cumulative_vaccinations numeric
)

insert into #percentage_population_vaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,
 dea.date) as cumulative_vaccinations

from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date 
where dea.continent is not null
--order by 2,3


select * 
from #percentage_population_vaccinated


-- Creating view to store data for later visualisations 

use PortfolioProject
go 

create view percentage_population_vaccinated
as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,
 dea.date) as cumulative_vaccinations

from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date 

where dea.continent is not null

--order by 2,3

select *, round(convert(float,cumulative_vaccinations)/convert(float,population), 4)*100 as percentage_vaccinated

from PortfolioProject..percentage_population_vaccinated

