## This project aims to explore data analysis skills in SQL using COVID-19 data sourced from Our World in Data: https://ourworldindata.org/coronavirus to answer scenarios. 

Skills utilized: Creating databases, Importing CSV files, JOINS, Aggregate functions 

Platform: PostgreSQL

##

-- Creating a database to begin COVID 19 data exploration. The database consists of 2 created tables, covid_vaccinations and covid_deaths.  


CREATE TABLE covid_vaccinations (iso_code VARCHAR, continent VARCHAR, location VARCHAR, date DATE, new_tests double precision, total_tests double precision, total_tests_per_thousand double precision,
								 new_tests_per_thousand double precision, new_tests_smoothed double precision, new_tests_smoothed_per_thousand double precision, positive_rate double precision, 
								 tests_per_case double precision, tests_units double precision, total_vaccinations double precision, people_vaccinated double precision, people_fully_vaccinated double precision, 
								 new_vaccinations double precision, new_vaccinations_smoothed double precision, total_vaccinations_per_hundred double precision, people_vaccinated_per_hundred double precision, 
								 people_fully_vaccinated_per_hundred double precision, new_vaccinations_smoothed_per_million double precision, stringency_index BIGINT, population_density BIGINT, median_age BIGINT, 
								 aged_65_older BIGINT, aged_70_older BIGINT, gdp_per_capita BIGINT, extreme_poverty BIGINT, cardiovasc_death_rate BIGINT, diabetes_prevalence BIGINT, 
								 female_smokers BIGINT, male_smokers BIGINT, handwashing_facilities BIGINT, hospital_beds_per_thousand BIGINT, life_expectancy BIGINT, human_development_index BIGINT);

	SELECT * FROM covid_vaccinations
	LIMIT 1000;
	

CREATE TABLE covid_deaths (iso_code VARCHAR, continent VARCHAR, location VARCHAR, date DATE, population BIGINT, total_cases BIGINT, 
						   new_cases BIGINT, new_cases_smoothed double precision, total_deaths BIGINT, new_deaths INTEGER, new_deaths_smoothed double precision,
						   total_cases_per_million double precision, new_cases_per_million double precision, new_cases_smoothed_per_million double precision, 
						   total_deaths_per_million double precision, new_deaths_per_million double precision, new_deaths_smoothed_per_million double precision, 
						   reproduction_rate real, icu_patients real, icu_patients_per_million real, hosp_patients real, hosp_patients_per_million real, 
						   weekly_icu_admissions real, weekly_icu_admissions_per_million real, weekly_hosp_admissions real, weekly_hosp_admissions_per_million real);

	SELECT * FROM covid_deaths
	LIMIT 1000;
	
-- Selecting initial data parameters.


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY location, date;


-- Viewing the total cases vs total deaths.
-- The result shows the likelihood of dying if you contract COVID-19 in your country.


SELECT location, date, total_cases, total_deaths, ROUND((total_deaths :: decimal / total_cases) * 100,7) as death_percentage
FROM covid_deaths
WHERE location LIKE '%Canada%' AND continent IS NOT NULL
ORDER BY location, date;


-- Viewing the total cases vs population.
-- The result shows the percentage of the population that contracted COVID


SELECT location, date, population, total_cases, ROUND((total_cases :: decimal / population) * 100,7) as contraction_percentage
FROM covid_deaths
WHERE location LIKE '%Canada%' AND continent IS NOT NULL
ORDER BY location, date;


-- Calculating countries with the highest infection rate in comparison to the population. 


SELECT location, population, MAX(total_cases) as highest_infection_count, ROUND(MAX((total_cases :: decimal / population) * 100),7) as contraction_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population
HAVING MAX(total_cases) IS NOT NULL
ORDER BY highest_infection_count DESC;


-- Calculating countries with the highest mortality rate per population. 


SELECT location, population, MAX(total_deaths) as total_death_count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population
HAVING MAX(total_deaths) IS NOT NULL
ORDER BY total_death_count DESC;


-- Calculating continents with the highest mortality rate per population.


SELECT continent, MAX(total_deaths) as total_death_count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;


--Calculating global mortality rate per date.

SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, ROUND(SUM(new_deaths) :: decimal / SUM(new_cases) * 100,7) as death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;


-- Performing an exploration on the total population vs vaccinations.


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations :: bigint, SUM(vac.new_vaccinations) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date)
FROM covid_deaths AS  dea
JOIN covid_vaccinations AS vac
ON dea.date = vac.date AND dea."location" = vac."location"
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date;



