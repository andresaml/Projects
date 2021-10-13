SELECT *
From PortfolioProject..CovidDeaths
Order by 3,4

--SELECT *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

--Select data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2


-- Looking at Total Cases vs Total Deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%venezuela'
Order by 1,2

-- Looking at Total Cases vs Population
Select location, date,  population,total_cases, (total_cases/population)*100 as PercentageOfCases
From PortfolioProject..CovidDeaths
--Where location like '%venezuela'
Order by 1,2


-- Looking at Countries with Highest Infection Rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentageOfCases
From PortfolioProject..CovidDeaths
--Where location like '%venezuela'
Group by location, population
Order by PercentageOfCases desc


-- Showing countries with Higheste Death Count per Population
Select location, population, MAX(cast(total_deaths as int)) as HighestDeathCount, MAX((cast(total_deaths as int)/population))*100 as PercentageOfDeaths
From PortfolioProject..CovidDeaths
--Where location like '%venezuela'
Where continent is not null -- We eliminated the continent count from the calculation
Group by location, population
Order by PercentageOfDeaths desc


-- Let's Break things down by continent

Select location, MAX(cast(total_deaths as int)) as HighestDeathCount, MAX((cast(total_deaths as int)/population))*100 as PercentageOfDeathsPerContinent
From PortfolioProject..CovidDeaths
--Where location like '%venezuela'
Where continent is null
Group by location
Order by PercentageOfDeathsPerContinent desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%venezuela'
where continent is not null
--Group by date
Order by 1,2



-- Looking at total population vs vaccination

Select  dea.continent, dea.location, dea.date, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3


--Use CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as Percentage_of_people_vaccinated
From PopvsVac


-- TEMP TABLE

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
PercentageOfPeopleVac numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
, (SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)/dea.population)*100 as PercentageOfPeopleVac
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVacCanada as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
, (SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)/dea.population)*100 as PercentageOfPeopleVac
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
and dea.location like '%canada'

Select *
From PercentPopulationVacCanada
