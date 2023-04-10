
Select *
From Portfolioproject..['CovidDeaths']
Where continent is not null
order by 3,4


--Select *
--From Portfolioproject..['CovidVaccinations']
--order by 3,4

Select location, date, total_cases, new_cases,total_deaths,population
From Portfolioproject..['CovidDeaths']
order by 1,2


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
From Portfolioproject..['CovidDeaths']
where location like '%India%'
order by 1,2


--Looking at Total Cases vs Population
--Shows what percentage of population got covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From Portfolioproject..['CovidDeaths']
--where location like '%India%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

Select location, Population, max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolioproject..['CovidDeaths']
--where location like '%India%'
Where continent is not null
Group by location, Population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death count per Population

Select location, max(cast(Total_deaths as int)) as TotalDeathCount
From Portfolioproject..['CovidDeaths']
--where location like '%India%'
Where continent is not null
Group by location
order by TotalDeathCount desc

--BREAKING THINGS DOWN BY CONTINENT
--Showing Continents with Highest Death Count per Population

Select continent, max(cast(Total_deaths as int)) as TotalDeathCount
From Portfolioproject..['CovidDeaths']
--where location like '%India%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


--Global Numbers

 Select date, SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
From Portfolioproject..['CovidDeaths']
--where location like '%India%'
where continent is not null
Group BY date
order by 1,2

Select SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
From Portfolioproject..['CovidDeaths']
--where location like '%India%'
where continent is not null
--Group BY date
order by 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--RollingPeopleVaccinated/population
From Portfolioproject..['CovidDeaths'] dea
Join Portfolioproject..['CovidVaccinations'] vac
  On dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE

with popvsvac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--RollingPeopleVaccinated/population
From Portfolioproject..['CovidDeaths'] dea
Join Portfolioproject..['CovidVaccinations'] vac
  On dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)
From popvsvac

--TEMP TABLE

Drop table if exists  #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--RollingPeopleVaccinated/population
From Portfolioproject..['CovidDeaths'] dea
Join Portfolioproject..['CovidVaccinations'] vac
  On dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)
From #PercentPopulationVaccinated

--Creating view to store data for visualization

Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--RollingPeopleVaccinated/population
From Portfolioproject..['CovidDeaths'] dea
Join Portfolioproject..['CovidVaccinations'] vac
  On dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null

Create view Globalnumbers as

Select SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
From Portfolioproject..['CovidDeaths']
--where location like '%India%'
where continent is not null
--Group BY date






