# Projekt SQL – Jan Růža

Tento projekt analyzuje dostupnost vybraných potravin v České republice ve vztahu k průměrným mzdám a vybraným ekonomickým ukazatelům (HDP, GINI, populace) v evropském kontextu.

## Použité tabulky

### Primární tabulka:

- `t_jan_ruza_project_SQL_primary_final` – sloučená data o mzdách a cenách potravin v ČR podle roku a odvětví

### Sekundární tabulka:

- `t_jan_ruza_project_SQL_secondary_final` – data o HDP, GINI a populaci v evropských zemích

## Shrnutí otázek a odpovědí

### 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

Analýza vývoje mezd podle odvětví ukazuje, že i když celkově mzdy spíše rostou, v některých letech a sektorech došlo k poklesu.

Konkrétně v roce 2013 došlo u ke snížení průměrné mzdy:

Celkový trend ale ukazuje, že ve většině odvětví mzdy meziročně rostou.

### 2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd? 

V roce 2006 bylo možné za průměrnou mzdu zakoupit 1,465.73 litrů mléka a 1,312.98 kg chleba, zatímco v roce 2018 to bylo 1,669.6 litrů mléka a 1,365.16 kg chleba.

To ukazuje, že reálná dostupnost základních potravin buď rostla, v závislosti na vývoji cen i mezd.

### 3. Která kategorie potravin zdražuje nejpomaleji (Je u ní nejnižší percentuální meziroční nárůst)?

**Na základě analýzy meziročních změn cen potravin jsme zjistili, že nejpomaleji zdražující potravinou je cukr krystalový.**

Jeho průměrná meziroční změna ceny dosahovala -1,92 %, tedy docházelo dokonce k mírnému zlevňování v průběhu sledovaných let.

### 4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

**Ve sledovaném období, nebyl žádný rok, kdy by růst cen potravin překročil 10 %.**

### 5. Má výška HDP vliv na změny ve mzdách a cenách potravin?

Mzdy reagují na změny HDP poměrně stabilně a pozitivně – růst HDP obvykle vede k růstu mezd (i když někdy se projeví až s ročním zpožděním).

Ceny potravin ale nejsou tak pevně navázané na HDP – mohou růst i v období ekonomického poklesu, a naopak.

To ukazuje, že HDP má vliv hlavně na mzdy, zatímco ceny potravin jsou závislé i na jiných faktorech, jako je např. sezónnost, sucho, ceny komodit nebo energetika.

## Popis mezivýsledků

- Tabulky `platy_rocni` a `ceny_rocni` byly vytvořeny pro agregaci dat po rocích.
- Ve finální tabulce byly potraviny propojeny s odvětvími podle společného roku.
- Tabulka sekundární byla filtrovaná na `Czech Republic` a evropské země.

## Chybějící nebo omezená data

- Data o cenách potravin končí v roce 2018, proto je finální tabulka omezena do tohoto roku.
- Některé roky v HDP nebo demografii mohou chybět pro určité země, ale nejsou pro hlavní analýzu ČR klíčové.

---

Projekt zpracoval: **Jan Růža**
