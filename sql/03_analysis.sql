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

SELECT state, COUNT(*) AS total_hospitals, COUNT(*) FILTER (WHERE overall_rating ~ '^[0-9]+$') AS rated_hospitals,
ROUND(COUNT(*) FILTER (WHERE overall_rating ~ '^[0-9]+$') * 100.0 / COUNT(*), 2) AS pct_rated_hospitals
FROM hospital_info
GROUP BY state
ORDER BY pct_rated_hospitals DESC, total_hospitals DESC
;

SELECT 
	state, 

	COUNT(*) FILTER (WHERE overall_rating ~ '^[0-9]+$') AS rated_hospitals, 
	COUNT(*) FILTER (WHERE overall_rating !~ '^[0-9]+$') AS unrated_hospitals,
	
	ROUND(
		COUNT(*) FILTER (
			WHERE emergency_services = 'Yes' 
			AND overall_rating ~ '^[0-9]+$'
		) * 100.0 
		/ NULLIF(COUNT(*) FILTER (WHERE overall_rating ~ '^[0-9]+$'), 0),
		2
	) AS pct_emergency_rated, 


	ROUND(
		COUNT(*) FILTER (
			WHERE emergency_services = 'Yes'
			AND overall_rating !~ '^[0-9]+$'
		) * 100.0 
		/ NULLIF(COUNT(*) FILTER (WHERE overall_rating !~ '^[0-9]+$'), 0)
		, 2
	) AS pct_emergency_unrated

FROM hospital_info
GROUP BY state
ORDER BY pct_emergency_rated DESC, pct_emergency_unrated DESC
;

SELECT 

	hospital_ownership, 

	COUNT(*) AS num_hospitals, 

	ROUND(
		COUNT(*)
		 * 100.0 
		 /SUM(COUNT(*)) OVER ()
		, 2) 
	AS pct_hospitals

FROM hospital_info
GROUP BY hospital_ownership
ORDER BY pct_hospitals DESC, hospital_ownership
;

SELECT

	hospital_ownership,

	COUNT(*) AS total_hospitals, 
	
	ROUND(COUNT(*) FILTER (WHERE emergency_services = 'Yes') * 100.0/ COUNT(*), 2) AS pct_emergency_services,

	ROUND(AVG(overall_rating::NUMERIC) FILTER(WHERE overall_rating ~ '^[0-9]+$'), 2) AS average_overall_rating,

	COUNT(*) FILTER (WHERE overall_rating ~ '^[0-9]+$') AS rated_hospitals

FROM hospital_info
GROUP BY hospital_ownership
ORDER BY average_overall_rating DESC NULLS LAST, rated_hospitals DESC
;

SELECT state, hospital_ownership, COUNT(*) AS n_hospitals
FROM hospital_info
GROUP BY state, hospital_ownership
;

WITH ownership_counts AS(
	SELECT state, hospital_ownership, COUNT(*) AS n_hospitals
	FROM hospital_info
	GROUP BY state, hospital_ownership
),

ranked AS(
	SELECT state, hospital_ownership, n_hospitals,
	ROW_NUMBER() OVER (PARTITION BY state ORDER BY n_hospitals DESC, hospital_ownership) AS rn
FROM ownership_counts
)
SELECT state, hospital_ownership, n_hospitals
FROM ranked
WHERE rn <= 3
ORDER BY state, rn
;

SELECT city_town, state, COUNT(*) AS num_hospitals
FROM hospital_info
GROUP BY city_town, state
ORDER BY num_hospitals DESC
LIMIT 10
;

WITH national_average AS(
	SELECT AVG(overall_rating::NUMERIC) AS national_avg_rating
	FROM hospital_info
	WHERE overall_rating ~ '^[0-9]+$'
),
state_avg AS(
	SELECT state, count(*) AS n_rated, AVG(overall_rating::NUMERIC) AS state_avg_rating
	FROM hospital_info
	WHERE overall_rating ~ '^[0-9]+$'
	GROUP BY state
	HAVING COUNT(*) >= 10
)
SELECT
	s.state,
	ROUND(s.state_avg_rating, 2) AS state_avg_rating,
	ROUND(n.national_avg_rating, 2) AS national_avg_rating,
	ROUND(s.state_avg_rating - n.national_avg_rating, 2) AS difference_from_national,
	s.n_rated
FROM state_avg AS s
CROSS JOIN national_average AS n
WHERE ABS(s.state_avg_rating - n.national_avg_rating) >= 0.50
ORDER BY ABS(s.state_avg_rating - n.national_avg_rating) DESC
;

SELECT facility_id, facility_name, state, zip_code
FROM hospital_info
WHERE zip_code IS NULL
OR NULLIF(TRIM(zip_code), '') IS NULL
OR zip_code !~ '[0-9]{5}$'
ORDER BY state, zip_code
LIMIT 50
;

SELECT 
	COUNT(*), 
	overall_rating, 
	ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM hospital_info), 2) AS pct_unrated
FROM hospital_info
WHERE overall_rating !~ '^[0-9]+$'
GROUP BY overall_rating
;

CREATE OR REPLACE VIEW state_metrics AS
SELECT
    state,

    COUNT(*) AS total_hospitals,

    COUNT(*) FILTER (
        WHERE overall_rating ~ '^[0-9]+$'
    ) AS rated_hospitals,

    ROUND(
        AVG(
            CASE
                WHEN overall_rating ~ '^[0-9]+$'
                THEN overall_rating::NUMERIC
            END
        ),
        2
    ) AS average_overall_rating,

    ROUND(
        COUNT(*) FILTER (
            WHERE emergency_services = 'Yes'
        ) * 100.0 / COUNT(*),
        2
    ) AS pct_emergency_services,

    ROUND(
        COUNT(*) FILTER (
            WHERE overall_rating ~ '^[0-9]+$'
              AND overall_rating::INT >= 4
        ) * 100.0
        / NULLIF(
            COUNT(*) FILTER (
                WHERE overall_rating ~ '^[0-9]+$'
            ),
            0
        ),
        2
    ) AS pct_highly_rated,

    ROUND(
        COUNT(*) FILTER (
            WHERE overall_rating ~ '^[0-9]+$'
              AND overall_rating::INT <= 2
        ) * 100.0
        / NULLIF(
            COUNT(*) FILTER (
                WHERE overall_rating ~ '^[0-9]+$'
            ),
            0
        ),
        2
    ) AS pct_lowly_rated

FROM hospital_info
GROUP BY state;

SELECT * FROM state_metrics
ORDER BY average_overall_rating DESC NULLS LAST, pct_highly_rated DESC
;