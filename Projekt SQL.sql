/*Projekt SQL – Jan Růža 
Tento projekt analyzuje dostupnost vybraných potravin v České republice ve vztahu k průměrným mzdám a vybraným ekonomickým ukazatelům (HDP, GINI, populace) v evropském kontextu.
Discord: SataGrizzly
*/

CREATE OR REPLACE TABLE platy_rocni AS
SELECT
  cpib.name AS branch_name,
  cp.payroll_year,
  ROUND(AVG(cp.value), 2) AS avg_salary
FROM czechia_payroll cp
JOIN czechia_payroll_value_type cpvt ON cp.value_type_code = cpvt.code
JOIN czechia_payroll_calculation cpc ON cp.calculation_code = cpc.code
JOIN czechia_payroll_industry_branch cpib ON cp.industry_branch_code = cpib.code
JOIN czechia_payroll_unit cpu ON cp.unit_code = cpu.code
WHERE 
  cpu.name = 'Kč'
  AND cpvt.name = 'Průměrná hrubá mzda na zaměstnance'
  AND cpc.name = 'Přepočtený'
GROUP BY cpib.name, cp.payroll_year
ORDER BY cp.payroll_year, cpib.name;

SELECT *
FROM platy_rocni;


CREATE OR REPLACE TABLE ceny_rocni AS
SELECT
  YEAR(cp.date_from) AS year,
  cat.name AS food_item,
  ROUND(AVG(cp.value), 2) AS avg_price
FROM czechia_price cp
JOIN czechia_price_category cat ON cp.category_code = cat.code
GROUP BY YEAR(cp.date_from), cat.name
ORDER BY year, cat.name;

SELECT *
FROM ceny_rocni cr ;



CREATE OR REPLACE TABLE t_jan_ruza_project_SQL_primary_final AS
SELECT
  p.payroll_year AS year,
  p.branch_name,
  c.food_item,
  c.avg_price,
  p.avg_salary,
  ROUND(p.avg_salary / c.avg_price, 2) AS purchasable_quantity
FROM platy_rocni p
JOIN ceny_rocni c ON p.payroll_year = c.year
ORDER BY p.payroll_year, p.branch_name, c.food_item;

SELECT *
FROM t_jan_ruza_project_sql_primary_final tjrpspf ;


CREATE OR REPLACE TABLE t_jan_ruza_project_SQL_secondary_final AS
SELECT
  c.country,
  e.year,
  e.gdp,
  e.gini,
  d.population
FROM economies e
JOIN countries c ON e.country = c.country
LEFT JOIN demographics d ON e.country = d.country AND e.year = d.year
WHERE c.continent = 'Europe'
ORDER BY c.country, e.year;

SELECT *
FROM t_jan_ruza_project_sql_secondary_final tjrpssf
WHERE country = 'Czech republic' AND gdp Is NOT null;


-- Otázka 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?



WITH mzdy AS (
  SELECT
    branch_name,
    year,
    AVG(avg_salary) AS avg_salary,
    LAG(AVG(avg_salary)) OVER (PARTITION BY branch_name ORDER BY year) AS prev_year_salary
  FROM t_jan_ruza_project_SQL_primary_final
  GROUP BY branch_name, year
)
SELECT
  branch_name,
  year,
  avg_salary,
  prev_year_salary,
  ROUND(avg_salary - prev_year_salary, 2) AS difference,
  ROUND(
    CASE 
      WHEN prev_year_salary > 0 THEN ((avg_salary - prev_year_salary) / prev_year_salary) * 100
      ELSE NULL
    END,
    2
  ) AS pct_change
FROM mzdy
ORDER BY difference, year , branch_name ;

/*
 
Vyhodnocení: Analýza vývoje mezd podle odvětví ukazuje, že i když celkově mzdy spíše rostou, v některých letech a sektorech došlo k poklesu.

Konkrétně v roce 2013 došlo u ke snížení průměrné mzdy:

Celkový trend ale ukazuje, že ve většině odvětví mzdy meziročně rostou.

*/


-- Otázka 2 - Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd? 

	



SELECT
  year,
  food_item,
  ROUND(AVG(purchasable_quantity), 2) AS avg_quantity
FROM t_jan_ruza_project_SQL_primary_final
WHERE 
  food_item IN ('Mléko polotučné pasterované', 'Chléb konzumní kmínový')
  AND year IN (2006, 2018)
GROUP BY year, food_item
ORDER BY food_item, year;

/*Vyhodnocení : V roce 2006 bylo možné za průměrnou mzdu zakoupit 1,465.73 litrů mléka a 1,312.98 kg chleba, zatímco v roce 2018 to bylo 1,669,6 litrů mléka a 1,365,16 kg chleba.
To ukazuje, že reálná dostupnost základních potravin buď rostla, v závislosti na vývoji cen i mezd.
*/



-- Otázka 3 - Která kategorie potravin zdražuje nejpomaleji (Je u ní nejnižší percentuální meziroční nárůst)?

WITH ceny AS (
  SELECT
    food_item,
    year,
    ROUND(AVG(avg_price), 2) AS avg_price
  FROM t_jan_ruza_project_SQL_primary_final
  GROUP BY food_item, year
),
zmeny AS (
  SELECT
    food_item,
    year,
    avg_price,
    LAG(avg_price) OVER (PARTITION BY food_item ORDER BY year) AS prev_price
  FROM ceny
),
rozdily AS (
  SELECT
    food_item,
    year,
    avg_price,
    prev_price,
    ROUND(
      CASE 
        WHEN prev_price > 0 THEN ((avg_price - prev_price) / prev_price) * 100
        ELSE NULL
      END, 2
    ) AS pct_change
  FROM zmeny
  WHERE prev_price IS NOT NULL
)
SELECT
  food_item,
  ROUND(AVG(pct_change), 2) AS avg_pct_growth
FROM rozdily
GROUP BY food_item
ORDER BY avg_pct_growth ASC
LIMIT 1;



/* Vyhodnocení: 
„Která potravinová kategorie zdražuje nejpomaleji?“

Na základě analýzy meziročních změn cen potravin jsme zjistili, že nejpomaleji zdražující potravinou je cukr krystalový.

Jeho průměrná meziroční změna ceny dosahovala -1,92 %, tedy docházelo dokonce k mírnému zlevňování v průběhu sledovaných let.

*/



-- Otázka 4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

WITH souhrn AS (
  SELECT
    year,
    ROUND(AVG(avg_price), 2) AS avg_price,
    ROUND(AVG(avg_salary), 2) AS avg_salary
  FROM t_jan_ruza_project_SQL_primary_final
  GROUP BY year
),
zmeny AS (
  SELECT
    year,
    avg_price,
    avg_salary,
    LAG(avg_price) OVER (ORDER BY year) AS prev_price,
    LAG(avg_salary) OVER (ORDER BY year) AS prev_salary
  FROM souhrn
),
rozdil AS (
  SELECT
    year,
    ROUND(((avg_price - prev_price) / prev_price) * 100, 2) AS growth_ceny_pct,
    ROUND(((avg_salary - prev_salary) / prev_salary) * 100, 2) AS growth_mzdy_pct,
    ROUND(((avg_price - prev_price) / prev_price) * 100, 2) -
    ROUND(((avg_salary - prev_salary) / prev_salary) * 100, 2) AS rozdil_pct
  FROM zmeny
  WHERE prev_price IS NOT NULL AND prev_salary IS NOT NULL
)
SELECT *
FROM rozdil
ORDER BY rozdil_pct DESC;


/*Vyhodnocení: Ve sledovaném období, nebyl žádný rok, kdy by růst cen potravin překročil 10%
 * */


-- Otázka 5 - Má výška HDP vliv na změny ve mzdách a cenách potravin?


WITH zaklad AS (
  SELECT
    p.year,
    ROUND(AVG(p.avg_salary), 2) AS avg_salary,
    ROUND(AVG(p.avg_price), 2) AS avg_price,
    s.gdp
  FROM t_jan_ruza_project_SQL_primary_final p
  JOIN t_jan_ruza_project_SQL_secondary_final s 
    ON p.year = s.year AND s.country = 'Czech Republic'
  GROUP BY p.year, s.gdp
),
zmeny AS (
  SELECT
    year,
    avg_salary,
    avg_price,
    gdp,
    LAG(avg_salary) OVER (ORDER BY year) AS prev_salary,
    LAG(avg_price) OVER (ORDER BY year) AS prev_price,
    LAG(gdp) OVER (ORDER BY year) AS prev_gdp
  FROM zaklad
)
SELECT
  year,
  ROUND(((avg_salary - prev_salary) / prev_salary) * 100, 2) AS mzdy_pct,
  ROUND(((avg_price - prev_price) / prev_price) * 100, 2) AS ceny_pct,
  ROUND(((gdp - prev_gdp) / prev_gdp) * 100, 2) AS hdp_pct
FROM zmeny
WHERE prev_salary IS NOT NULL AND prev_price IS NOT NULL AND prev_gdp IS NOT NULL
ORDER BY year;


 
/* Vyhodnocení: 

Mzdy reagují na změny HDP poměrně stabilně a pozitivně – růst HDP obvykle vede k růstu mezd (i když někdy se projeví až s ročním zpožděním).

Ceny potravin ale nejsou tak pevně navázané na HDP – mohou růst i v období ekonomického poklesu, a naopak.

To ukazuje, že HDP má vliv hlavně na mzdy, zatímco ceny potravin jsou závislé i na jiných faktorech, jako je např. sezónnost, sucho, ceny komodit nebo energetika.

*/

