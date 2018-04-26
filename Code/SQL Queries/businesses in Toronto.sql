SELECT DISTINCT b.*, c.category
FROM (SELECT b1.*
	  FROM business b1
      INNER JOIN category c1
		ON c1.business_id = b1.id
      WHERE c1.category = 'Restaurants') b
INNER JOIN (SELECT *
			FROM category 
            WHERE category <> 'Restaurants') c
	ON c.business_id = b.id
WHERE city = "Toronto"
	AND is_open = 1
ORDER BY b.id
