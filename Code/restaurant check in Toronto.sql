SELECT c.id, c.business_id, b.`name`, b.stars, b.review_count,  c.`date`, c.`count`
from checkin c
INNER JOIN (SELECT b1.*
			FROM business b1
			INNER JOIN category c1
				ON c1.business_id = b1.id
			WHERE c1.category IN (    	'American (New)',
										'American (Traditional)',
                                        'Asian Fusion',
										'Cajun/Creole',
										'Canadian (New)',
										'Cantonese',
                                        'Caraibbean',
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
										'Syrian',
										'Thai',
										'Turkish',
										'Vietnamese')
			AND   b1.city = 'Toronto'
            AND   b1.state = 'ON') b
		ON c.business_id = b.id
