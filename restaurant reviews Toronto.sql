SELECT r.*
FROM review r
INNER JOIN (SELECT b1.*
			FROM business b1
			INNER JOIN category c1
				ON c1.business_id = b1.id
			WHERE c1.category = 'Restaurants'
			AND   b1.city = 'Toronto'
            AND   b1.state = 'ON') b
	ON r.business_id = b.id