SELECT state, COUNT(*)
FROM hospital_info
GROUP BY state
ORDER BY COUNT(*) DESC
;

SELECT overall_rating, COUNT(*)
FROM hospital_info
GROUP BY overall_rating
ORDER BY overall_rating DESC
;

SELECT count(facility_name), state, emergency_services
FROM hospital_info
GROUP BY state, emergency_services
ORDER BY state, emergency_services
; 

SELECT state, 
ROUND (COUNT(*) FILTER (WHERE emergency_services = 'Yes') * 100.0 / COUNT(*), 2) AS percentage_emergency_services
FROM hospital_info
WHERE emergency_services IN ('Yes', 'No')
GROUP BY state
ORDER BY percentage_emergency_services DESC
;

SELECT state, ROUND(AVG(overall_rating::INT), 2) AS average_overall_rating, COUNT(*) FILTER (WHERE overall_rating ~ '^[0-9]+$') AS number_of_hospitals
FROM hospital_info
WHERE overall_rating ~ '^[0-9]+$'
GROUP BY state
HAVING count(*) >= 10
ORDER BY average_overall_rating DESC
;

SELECT hospital_ownership, COUNT(*) AS count_hospital_ownership
FROM hospital_info
GROUP BY hospital_ownership
ORDER BY count_hospital_ownership DESC
;

SELECT hospital_ownership, ROUND(AVG(overall_rating::NUMERIC), 2) AS average_overall_rating
FROM hospital_info
WHERE overall_rating ~ '^[0-9]+$'
GROUP BY hospital_ownership
ORDER BY average_overall_rating DESC
;

SELECT * FROM hospital_info;

SELECT state, ROUND(COUNT(*) FILTER (WHERE overall_rating::NUMERIC >= 4) * 100.0 / COUNT(*), 2) AS pct_highly_rated
FROM hospital_info
WHERE overall_rating ~ '^[0-9]+$'
GROUP BY state
ORDER BY pct_highly_rated DESC
LIMIT 10
;

SELECT state, ROUND(COUNT(*) FILTER (WHERE overall_rating::NUMERIC <= 2) * 100.0 / COUNT(*), 2) AS pct_lowly_rated
FROM hospital_info
WHERE overall_rating ~ '^[0-9]+$'
GROUP BY state
HAVING COUNT(*) >= 20
ORDER BY pct_lowly_rated DESC
;

SELECT birthing_friendly, COUNT(*) AS n_hospitals, ROUND(AVG(overall_rating::NUMERIC), 2) AS average_overall_rating
FROM hospital_info
WHERE overall_rating ~ '^[0-9]+$'
GROUP BY birthing_friendly
;

SELECT state, COUNT(*) FILTER(WHERE overall_rating ~ '^[0-9]+$') AS n_rated_hospitals, 
ROUND(COUNT(*) FILTER (WHERE emergency_services = 'Yes') * 100.0 / COUNT(*), 2) AS pct_emergency_services,
ROUND(COUNT(*) FILTER (WHERE overall_rating::NUMERIC >= 4) * 100.0 / COUNT(*), 2) AS pct_highly_rated,
ROUND(AVG(overall_rating::NUMERIC), 2) AS average_overall_rating
FROM hospital_info
WHERE overall_rating ~ '^[0-9]+$'
GROUP BY state
ORDER BY average_overall_rating DESC
;