--Exploring Covid Death Data
select * from Portfolio_Project..Covid_Deaths$

select location, date, population, total_cases, total_deaths, new_cases from Portfolio_Project..Covid_Deaths$

--shows the likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage from Portfolio_Project..Covid_Deaths$ where location = 'canada'

--shows what percentage of population got Covid in perticular country
select location, date, total_cases, population, (total_cases/population)*100 as InfectionPercentage from Portfolio_Project..Covid_Deaths$ where location = 'canada'

--Looking at the countries with the highest infection rate compared to population
select location, population, MAX(total_cases) as HighestInfection, MAX((total_cases/population)*100) as PercentagePopulationIngected from Portfolio_Project..Covid_Deaths$ group by location, population order by PercentagePopulationIngected desc

--Looking at highest death count in countries
select location, MAX(total_deaths) as MaximumDeath from Portfolio_Project..Covid_Deaths$ where continent is not null group by location order by MaximumDeath desc

--Looking at highest death count in continent
select continent, MAX(total_deaths) as TotalDeathCount from Portfolio_Project..Covid_Deaths$ where continent is not null group by continent order by TotalDeathCount desc

--Looking at global numbers
select date, sum(new_cases) as TotalNewCases, sum(new_deaths) as TotalNewDeaths, sum(new_deaths)/nullif(sum(new_cases),0)*100 as DeathPercentage from Portfolio_Project..Covid_Deaths$ where continent is not null group by date order by 1,2

--Exploring Covid Vaccination Data
select * from Portfolio_Project..covid_data$

--joining both the Table
select * from Portfolio_Project..Covid_Deaths$ as de join Portfolio_Project..Covid_Vaccinations$ as ve on de.location = ve.location and de.date = ve.date order by 1,2

--Locking at Total Population vs Vaccination
select de.continent, de.location, de.date, de.population, ve.new_vaccinations, sum(ve.new_vaccinations) over (partition by de.location order by de.location, de.date) as Rolling_Total_Vaccination
from Portfolio_Project..Covid_Deaths$ as de join Portfolio_Project..Covid_Vaccinations$ as ve 
on de.location = ve.location and de.date = ve.date 
where de.continent is not null order by 1,2,3

--use CTE

with PopvsVac (Continent, Location, Date, Population, new_vaccination, Rolling_Total_Vaccination)
as
(
select de.continent, de.location, de.date, de.population, ve.new_vaccinations, sum(ve.new_vaccinations) over (partition by de.location order by de.location, de.date) as Rolling_Total_Vaccination
from Portfolio_Project..Covid_Deaths$ as de join Portfolio_Project..Covid_Vaccinations$ as ve 
on de.location = ve.location and de.date = ve.date 
where de.continent is not null
)

select *, (Rolling_Total_Vaccination/Population)*100 as Percentage_Population_Vaccinated from PopvsVac

--Temp Table

drop table if exists #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
Rolling_Total_Vaccination float
)

Insert into #PercentagePopulationVaccinated
select de.continent, de.location, de.date, de.population, ve.new_vaccinations, sum(ve.new_vaccinations) over (partition by de.location order by de.location, de.date) 
from Portfolio_Project..Covid_Deaths$ as de join Portfolio_Project..Covid_Vaccinations$ as ve
on de.location = ve.location and de.date = ve.date
where de.continent is not null

select *, (Rolling_Total_Vaccination/Population)*100 as Percentage_Population_Vaccinated from #PercentagePopulationVaccinated

--creating view to store data for visualization

create view PercentagePopulationVaccinated as 
select de.continent, de.location, de.date, de.population, ve.new_vaccinations, sum(ve.new_vaccinations) over (partition by de.location order by de.location, de.date) as Percentage_Population_Vaccinated
from Portfolio_Project..Covid_Deaths$ as de join Portfolio_Project..Covid_Vaccinations$ as ve
on de.location = ve.location and de.date = ve.date
where de.continent is not null

select * from PercentagePopulationVaccinated
