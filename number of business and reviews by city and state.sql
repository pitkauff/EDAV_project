
SELECT b.city, b.state, b.NumberOfBusinesses, r.NumberOfReviews
FROM (
	SELECT city, state, COUNT(*) AS NumberOfBusinesses
	FROM business
	GROUP BY state, city
	ORDER BY COUNT(*) DESC ) b
INNER JOIN (
	SELECT b1.city, b1.state, COUNT(*) NumberOfReviews
    FROM business b1
    INNER JOIN review r
		ON b1.id = r.business_id
    GROUP BY b1.city, b1.state
    HAVING COUNT(*) >= 1000 ) r
ON b.city = r.city
AND b.state = r.state