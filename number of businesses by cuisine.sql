SELECT 	b.city,
		b.state,
        c.category,
        COUNT(*) as NumberOfRestaurants
FROM business b
INNER JOIN category c 
	ON b.id = c.business_id
WHERE c.category IN (	'American (New)',
						'American (Traditional)',
						'Cajun/Creole',
                        'Canadian (New)',
						'Cantonese',
						'Chinese',
						'Cuban',
						'Ethiopian',
                        'French',
						'Greek',
						'Halal',
						'Indian',
						'Indonesian',
						'Italian',
						'Japanese',
						'Korean',
						'Malaysian',
						'Mexican',
						'Middle Eastern',
						'Pakistani',
						'Peruvian',
						'Singaporean',
						'Thai',
						'Turkish',
						'Vietnamese'
					)
GROUP BY b.city, b.state, c.category
ORDER BY city, state, category
			