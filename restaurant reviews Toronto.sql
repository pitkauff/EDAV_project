SELECT 	r.id,
		r.business_id,
        r.user_id,
        r.stars,
        r.`date`,
        REPLACE(REPLACE(r.`text`,'"',''),',','') AS `text`,
        r.useful,
        r.funny,
        r.cool,
        CASE	WHEN e.id IS NULL
				THEN 'No'
                ELSE 'Yes' END AS elite
FROM review r
INNER JOIN (SELECT b1.*
			FROM business b1
			INNER JOIN category c1
				ON c1.business_id = b1.id
			WHERE c1.category = 'Restaurants'
			AND   b1.city = 'Toronto'
            AND   b1.state = 'ON') b
	ON r.business_id = b.id
LEFT JOIN elite_years e
	ON r.user_id = e.user_id
    AND YEAR(r.`date`) = e.`year`