/****** COVID DATA EXPLORATORY ANALYSIS ******/
SELECT  
      [location]
      ,[date]
      ,[total_cases]
      ,[new_cases]
      ,[total_deaths]
      ,[population]
  FROM [trainingsql].[dbo].[CovidDeaths]
  ORDER BY  [location],[date]

--Continent column is NUll and location column consist of each continent and world, which may mislead the analysis
--so,we need to include continent column is not null(to filter the records)
SELECT DISTINCT 
      [continent]
      ,[location]
  FROM [trainingsql].[dbo].[CovidDeaths]
  WHERE continent IS NOT NULL
  ORDER BY  [continent]

-- Total Number of Continent Africa,Asia,Europe,North America,Oceania,South America; countries of each continent
--Change the data types of [total_cases],[total_deaths] to numeric 
--Top 5 countries are USA,INDIA,BRAZIL,RUSSIA,FRANCE --according to the Number Of cases
--
ALTER TABLE [trainingsql].[dbo].[CovidDeaths]
ALTER COLUMN [total_cases] float 
ALTER TABLE [trainingsql].[dbo].[CovidDeaths]
ALTER COLUMN [total_deaths] float

--CHINA,INDIA,USA,INDONESIA,PAKISTAN --Top 5 countries in population
--by end of the Year Only 1.3% of population had effected by COVID (INDIA)
--FROM March 11 2020,Deaths started in India.They is no continuous incease in death % up and down.Even though total cases are
--increased throughout the year,death % is 1.1% at the end of the year.
--More likely affected people were recovered.
SELECT [location] ,[date],[total_deaths],[total_cases],([total_cases]/[population])*100 AS [Total CASES%]
FROM [trainingsql].[dbo].[CovidDeaths]
WHERE continent IS NOT NULL AND location LIKE 'India'

SELECT [location] ,[date],[total_cases],([total_deaths]/[total_cases])*100 AS [%OfDeathsOverTotalCases]
FROM [trainingsql].[dbo].[CovidDeaths]
WHERE continent IS NOT NULL AND location LIKE 'India'

--Countries with highest infection rate 

SELECT [location],[population],MAX([total_cases]) HigestInfectedPeople,MAX(([total_cases]/[population]))*100 AS [Total CASES%]
FROM [trainingsql].[dbo].[CovidDeaths]
WHERE continent IS NOT NULL 
GROUP BY location,[population]
ORDER BY MAX(([total_cases]/[population]))*100 DESC

--Higest death count for each country
--US,BRAZIL,MEXOCO,INDIA,UK are the top 5 countries of high death count
--By Countries
SELECT [location], MAX([total_deaths]) AS [DeathCount]
FROM [trainingsql].[dbo].[CovidDeaths]
WHERE continent IS NOT NULL 
GROUP BY [location]
ORDER BY MAX([total_deaths]) DESC

--By continents
SELECT continent , MAX([total_deaths]) AS [DeathCount]
FROM [trainingsql].[dbo].[CovidDeaths]
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY MAX([total_deaths]) DESC

--Date wise total_deaths and Total_Cases across the world

SELECT  
       [date]
      ,SUM([new_cases]) AS Total_Cases
      ,SUM([total_deaths]) AS Death_Cases
      ,SUM([new_cases])/SUM([total_deaths]) AS [Death%]
FROM [trainingsql].[dbo].[CovidDeaths]
WHERE continent IS NOT NULL 
GROUP BY [date]
ORDER BY [date],SUM([new_cases])

--Over all the world Total Cases and Death

SELECT  
       SUM([new_cases]) AS Total_Cases
      ,SUM([total_deaths]) AS Death_Cases
      ,SUM([new_cases])/SUM([total_deaths]) AS [Death%]
FROM [trainingsql].[dbo].[CovidDeaths]
WHERE continent IS NOT NULL 

--Total number of people are vaccinated
WITH NumberOfVaccination
AS
(
SELECT 
	 dea.continent,
	 dea.location,
	 dea.date,
	 dea.total_cases,
	 dea.population,
	 vac.[new_vaccinations],
	 SUM(CONVERT(int,vac.[new_vaccinations]))OVER(PARTITION BY  dea.location ORDER BY  dea.location,
	 dea.date ) Rolling_New_Vaccination
FROM [trainingsql].[dbo].[CovidDeaths] dea
INNER JOIN [trainingsql].[dbo].[CovidVaccinations] vac
ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent IS NOT NULL AND dea.location IN( 'India','New Zealand')
)
SELECT *,(Rolling_New_Vaccination/population)*100 AS PercentageOfPeopleVaccinated
FROM NumberOfVaccination
