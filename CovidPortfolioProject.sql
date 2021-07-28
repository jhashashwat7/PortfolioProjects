Select *
From Portfolio_Project..CovidDeaths
Where continent is not null
order by 3,4

/*Select *
From Portfolio_Project..CovidVaccinations
order by 3,4;*/

Select Location, date, total_cases, new_cases,total_deaths, population
From Portfolio_Project..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contact Covid in your Country
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From Portfolio_Project..CovidDeaths
Where location like '%India%'
order by 1,2

--Looking at the total cases v/s Population
Select Location, date, total_cases,population, (total_cases/population)*100 AS CasesPercentage
From Portfolio_Project..CovidDeaths
Where location like '%India%'
order by 1,2

--Looking at Countries with highest Infection Rate compared to Population

Select Location,population , MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS CasesPercentage
From Portfolio_Project..CovidDeaths
--Where location like '%India%'
Group By Location, population
order by CasesPercentage desc




--Showing Countries with the Highest Death Count per Population

Select Location , MAX(cast(total_deaths as int)) AS TotalDeathCount
From Portfolio_Project..CovidDeaths
--Where location like '%India%'
Where continent is not null
Group By Location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT


Select continent , MAX(cast(total_deaths as int)) AS TotalDeathCount
From Portfolio_Project..CovidDeaths
--Where location like '%India%'
Where continent is NOT null
Group By continent
order by TotalDeathCount desc


--Showing the continents with the highest death count
Select location , MAX(cast(total_deaths as int)) AS TotalDeathCount
From Portfolio_Project..CovidDeaths
--Where location like '%India%'
Where continent is  null
Group By location
order by TotalDeathCount desc


--Global Numbers

Select  date, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage--,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From Portfolio_Project..CovidDeaths
--Where location like '%India%'
where continent is not null
Group By date
order by 1,2


--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
As
(

Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
 --order by 2,3

  )
  Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac



--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vacciantions numeric,
RollingPEopleVaccinated numeric
)
Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
 --order by 2,3

 Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create View PopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
 --order by 2,3