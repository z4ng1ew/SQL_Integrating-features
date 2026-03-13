COMMENT ON COLUMN person_discounts.id 
    IS 'primary key identifier';

COMMENT ON COLUMN person_discounts.person_id 
    IS 'person identifier';

COMMENT ON COLUMN person_discounts.pizzeria_id 
    IS 'pizzeria identifier';

COMMENT ON COLUMN person_discounts.discount 
    IS 'discount for pair person and pizzeria';

COMMENT ON TABLE person_discounts 
    IS 'Discounts for persons';


SELECT COUNT(*) = 5 AS check
FROM pg_description
WHERE objoid = 'person_discounts'::regclass;