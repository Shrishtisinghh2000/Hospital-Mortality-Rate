-- Updating missing ethnicity values to 'Mixed'
UPDATE HospitalMortalityRateD
SET ethnicity = CASE
    WHEN ethnicity = '' THEN 'Mixed'
    ELSE ethnicity
    END;

-- Mortality Analysis

-- Total hospital deaths and mortality rate
SELECT 
    COUNT(CASE WHEN hospital_death = 1 THEN 1 END) AS total_hospital_deaths, 
    ROUND(COUNT(CASE WHEN hospital_death = 1 THEN 1 END)*100/COUNT(*),2) AS mortality_rate
FROM HospitalMortalityRateD;

-- Death count by ethnicity
SELECT 
    ethnicity, 
    COUNT(hospital_death) as total_hospital_deaths
FROM HospitalMortalityRateD
WHERE hospital_death = '1'
GROUP BY ethnicity;

-- Death count by gender
SELECT 
    gender, 
    COUNT(hospital_death) as total_hospital_deaths
FROM HospitalMortalityRateD
WHERE hospital_death = '1'
GROUP BY gender;

-- Age Analysis

-- Comparison of average and max ages of patients who died and survived
SELECT 
    hospital_death,
    ROUND(AVG(age),2) as avg_age,
    MAX(age) as max_age
FROM HospitalMortalityRateD
GROUP BY hospital_death;

-- Distribution of patients by age intervals
SELECT
    CONCAT(FLOOR(age/10)*10, '-', FLOOR(age/10)*10+9) AS age_interval,
    COUNT(*) AS patient_count
FROM HospitalMortalityRateD
GROUP BY FLOOR(age/10)*10
ORDER BY age_interval;


-- Comparative Analysis

-- Comparison of patients' mortality between different age groups
SELECT
    CASE
        WHEN age < 40 THEN 'Under 40'
        WHEN age >= 40 AND age < 60 THEN '40-59'
        WHEN age >= 60 AND age < 80 THEN '60-79'
        ELSE '80 and above'
    END AS age_group,
    ROUND(AVG(apache_4a_hospital_death_prob), 3) AS average_death_prob
FROM HospitalMortalityRateD
GROUP BY 
    CASE
        WHEN age < 40 THEN 'Under 40'
        WHEN age >= 40 AND age < 60 THEN '40-59'
        WHEN age >= 60 AND age < 80 THEN '60-79'
        ELSE '80 and above'
    END
ORDER BY age_group;


-- Analysis by ICU Admit Source

-- Mortality analysis by ICU admit source
SELECT 
    icu_admit_source,
    COUNT(CASE WHEN hospital_death = '1' THEN 1 END) as amount_that_died,
    COUNT(CASE WHEN hospital_death = '0' THEN 1 END) as amount_that_survived
FROM HospitalMortalityRateD
GROUP BY icu_admit_source;

-- Analysis by Comorbidities

-- Percentage of patients with each comorbidity among those who died
SELECT
    ROUND(SUM(CASE WHEN aids = 1 THEN 1 ELSE 0 END) * 100 / COUNT(*),2) AS aids_percentage,
    ROUND(SUM(CASE WHEN cirrhosis = 1 THEN 1 ELSE 0 END) * 100 / COUNT(*),2) AS cirrhosis_percentage,
    ROUND(SUM(CASE WHEN diabetes_mellitus = 1 THEN 1 ELSE 0 END) * 100 / COUNT(*),2) AS diabetes_percentage,
    ROUND(SUM(CASE WHEN hepatic_failure = 1 THEN 1 ELSE 0 END) * 100 / COUNT(*),2) AS hepatic_failure_percentage,
    ROUND(SUM(CASE WHEN immunosuppression = 1 THEN 1 ELSE 0 END) * 100 / COUNT(*),2) AS immunosuppression_percentage,
    ROUND(SUM(CASE WHEN leukemia = 1 THEN 1 ELSE 0 END) * 100 / COUNT(*),2) AS leukemia_percentage,
    ROUND(SUM(CASE WHEN lymphoma = 1 THEN 1 ELSE 0 END) * 100 / COUNT(*),2) AS lymphoma_percentage,
    ROUND(SUM(CASE WHEN solid_tumor_with_metastasis = 1 THEN 1 ELSE 0 END) * 100 / COUNT(*),2) AS solid_tumor_percentage
FROM HospitalMortalityRateD
WHERE hospital_death = 1;

-- Elective Surgery Analysis

-- Percentage of patients who underwent elective surgery
SELECT
    COUNT(CASE WHEN elective_surgery = 1 THEN 1 END)*100/COUNT(*) AS elective_surgery_percentage
FROM HospitalMortalityRateD;

-- Average weight and height for male & female patients who underwent elective surgery
SELECT
    ROUND(AVG(CASE WHEN gender = 'M' THEN weight END),2) AS avg_weight_male,
    ROUND(AVG(CASE WHEN gender = 'M' THEN height END),2) AS avg_height_male,
    ROUND(AVG(CASE WHEN gender = 'F' THEN weight END),2) AS avg_weight_female,
    ROUND(AVG(CASE WHEN gender = 'F' THEN height END),2) AS avg_height_female
FROM HospitalMortalityRateD
WHERE elective_surgery = 1;

-- ICU Analysis

-- Top 10 ICUs with the highest hospital death probability

SELECT TOP 10
    icu_type, 
    apache_4a_hospital_death_prob AS hospital_death_prob
FROM HospitalMortalityRateD
ORDER BY apache_4a_hospital_death_prob DESC;


-- Average length of stay at each ICU for patients who survived and those who didn't
SELECT
    icu_type,
    ROUND(AVG(CASE WHEN hospital_death = 1 THEN pre_icu_los_days END), 2) AS avg_icu_stay_death,
    ROUND(AVG(CASE WHEN hospital_death = 0 THEN pre_icu_los_days END), 2) AS avg_icu_stay_survived
FROM HospitalMortalityRateD
GROUP BY icu_type
ORDER BY icu_type;

-- BMI Analysis

-- Average BMI for patients that died based on ethnicity
SELECT
    ethnicity,
    ROUND(AVG(bmi),2) AS average_bmi
FROM HospitalMortalityRateD
WHERE bmi IS NOT NULL
AND hospital_death = '1'
GROUP BY ethnicity;

-- Death percentage for each ethnicity
SELECT
    ethnicity,
    ROUND(COUNT(CASE WHEN hospital_death = 1 THEN 1 END) * 100 / (SELECT COUNT(*) FROM HospitalMortalityRateD), 2) AS death_percentage
FROM HospitalMortalityRateD
GROUP BY ethnicity;

-- BMI category distribution
SELECT
    COUNT(*) AS patient_count,
    CASE
        WHEN bmi < 18.5 THEN 'Underweight'
        WHEN bmi >= 18.5 AND bmi < 25 THEN 'Normal'
        WHEN bmi >= 25 AND bmi < 30 THEN 'Overweight'
        ELSE 'Obese'
    END AS bmi_category
FROM (
    SELECT
        patient_id,
        ROUND(bmi, 2) AS bmi
    FROM HospitalMortalityRateD
    WHERE bmi IS NOT NULL
) AS subquery
GROUP BY 
    CASE
        WHEN bmi < 18.5 THEN 'Underweight'
        WHEN bmi >= 18.5 AND bmi < 25 THEN 'Normal'
        WHEN bmi >= 25 AND bmi < 30 THEN 'Overweight'
        ELSE 'Obese'
    END
ORDER BY bmi_category;


-- ICU Type and BMI Analysis

-- Hospital death probabilities where the ICU type is 'SICU' and BMI is above 30
SELECT
    patient_id,
    apache_4a_hospital_death_prob as hospital_death_prob
FROM HospitalMortalityRateD
WHERE icu_type = 'SICU' AND bmi > 30
ORDER BY hospital_death_prob DESC;
