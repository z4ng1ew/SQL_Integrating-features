DROP SEQUENCE IF EXISTS seq_person_discounts CASCADE;

CREATE SEQUENCE seq_person_discounts 
    START 1;

ALTER TABLE person_discounts 
    ALTER COLUMN id SET DEFAULT NEXTVAL('seq_person_discounts');

SELECT SETVAL(
    'seq_person_discounts', 
    (SELECT COUNT(*) + 1 FROM person_discounts)
);


SELECT 
    COUNT(*) = 1 AS check1,
    MAX("start_value") = 1 AS check2,
    MAX("last_value") > 5 AS check3
FROM pg_sequences
WHERE sequencename = 'seq_person_discounts';