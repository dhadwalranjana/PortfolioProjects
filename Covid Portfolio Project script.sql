create database portfolio_project;
Select * FROM portfolio_project.coviddeaths
where continent is not NULL
order by 3,4

-----Select * FROM portfolio_project.covidvaccination
-----order by 3,4

Select Location, date, total_cases, new_cases,total_deaths, population
 FROM portfolio_project.coviddeaths
order by 1,2

--Checking total cases vs total deaths
--Shows the likelihood of dying if someone contacts covid in India
Select Location, date, total_cases,total_deaths, 
Round((total_deaths/total_cases)*100,2) as Deathpage
 FROM portfolio_project.coviddeaths
 where location like '%India%'
order by 1,2

--Looking at total case vs Population

Select Location, date, total_cases, CONCAT(Population/10000000,' Cr') as Population, 
Round((total_cases/Population)*100,0) as Populationpage
 FROM portfolio_project.coviddeaths
 where location like '%India%'
order by 1,2

---Countries with highest infection rate compared to population
Select Location, Population, 
Max(total_cases) as higest_inf_count,
Max((total_cases/Population)*100) as infectionPopulationpage
 FROM portfolio_project.coviddeaths
 Group by Location, Population
Order by infectionPopulationpage desc

--Showing the countries with highest death count per population
Select Location, Max(CAST(Total_deaths as UNSIGNED ) ) as totaldeathscount
 FROM portfolio_project.coviddeaths
 where continent is not NULL
 Group by Location
Order by totaldeathscount desc

---Breaking things by CONTINENT

--- Showing the continent with highest deathcount
Select continent, Max(CAST(Total_deaths as UNSIGNED ) ) as totaldeathscount
 FROM portfolio_project.coviddeaths
 where continent is not NULL
 Group by continent
Order by totaldeathscount desc

----GLOBAL NUMBERS
Select  date, Sum(new_cases) as total_cases, SUM(new_deaths) as total_deaths,
ROUND((SUM(new_deaths)/Sum(new_cases))*100,2) as Deathpage
 FROM portfolio_project.coviddeaths
 where continent is not NULL
Group by date
order by 1,2

---total_cases
Select   Sum(new_cases) as total_cases, SUM(new_deaths) as total_deaths,
ROUND((SUM(new_deaths)/Sum(new_cases))*100,2) as Deathpage
 FROM portfolio_project.coviddeaths
 where continent is not NULL
 
 
 ----Looking at total population vs Vaccination
Select cd.continent, cd.location, cd.date, 
 cd.population, cv.new_vaccinations, 
 SUM(cv.new_vaccinations ) OVER (Partition by cd.location order by cd.location, cd.date) as rollingpeoplevaccinated
 
 FROM portfolio_project.covidvaccination  as cv
 JOIN  portfolio_project.coviddeaths as cd ON cv.Location = cd.Location
 and cd.date =  cv.date
  where cd.continent is not NULL
 order by 2,3
 
 ---USE CTE
 
With PopvsVac (continent, Location, Date, Population, new_vaccinations, rollingpeoplevaccinated)
as
(
 Select cd.continent, cd.location, cd.date, 
 cd.population, cv.new_vaccinations, 
 SUM(cv.new_vaccinations ) OVER (Partition by cd.location order by cd.location, cd.date) as rollingpeoplevaccinated
 
 FROM portfolio_project.covidvaccination  as cv
 JOIN  portfolio_project.coviddeaths as cd ON cv.Location = cd.Location
 and cd.date =  cv.date
  where cd.continent is not NULL
 )
 Select * , ROUND((rollingpeoplevaccinated/population)*100,2) 
 FROM PopvsVac
 
 
 -----TEMPTABLE
 
DROP Table if exists Percentpoupulationvaccinated;
Create Table Percentpoupulationvaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date date, 
population nvarchar(255),
new_vaccinations nvarchar(255),
rollingpeoplevaccinated numeric
);
Insert into  Percentpoupulationvaccinated
Select cd.continent, cd.location, cd.date, 
 cd.population, cv.new_vaccinations, 
 SUM(cv.new_vaccinations ) OVER (Partition by cd.location order by cd.location, cd.Date) as rollingpeoplevaccinated
 FROM portfolio_project.covidvaccination  as cv
 JOIN  portfolio_project.coviddeaths as cd ON cv.Location = cd.Location
 and cd.Date =  cv.date ;

Select * , (rollingpeoplevaccinated/population)*100
 FROM Percentpoupulationvaccinated
 
 ----Creating a view to store data for visulazations 
 Create View  Percentpoupulationvaccination as
Select cd.continent, cd.location, cd.date, 
 cd.population, cv.new_vaccinations, 
 SUM(cv.new_vaccinations ) OVER (Partition by cd.location order by cd.location, cd.Date) as rollingpeoplevaccinated
 FROM portfolio_project.covidvaccination  as cv
 JOIN  portfolio_project.coviddeaths as cd ON cv.Location = cd.Location
 and cd.Date =  cv.date 
 
 Select *
 FROM Percentpoupulationvaccination








