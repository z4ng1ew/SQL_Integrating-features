ALTER TABLE person_discounts 
    DROP CONSTRAINT IF EXISTS ch_nn_person_id;

ALTER TABLE person_discounts 
    ADD CONSTRAINT ch_nn_person_id 
    CHECK (person_id IS NOT NULL);


ALTER TABLE person_discounts 
    DROP CONSTRAINT IF EXISTS ch_nn_pizzeria_id;

ALTER TABLE person_discounts 
    ADD CONSTRAINT ch_nn_pizzeria_id 
    CHECK (pizzeria_id IS NOT NULL);


ALTER TABLE person_discounts 
    DROP CONSTRAINT IF EXISTS ch_nn_discount;

ALTER TABLE person_discounts 
    ADD CONSTRAINT ch_nn_discount 
    CHECK (discount IS NOT NULL);


ALTER TABLE person_discounts 
    ALTER COLUMN discount SET DEFAULT 0;


ALTER TABLE person_discounts 
    DROP CONSTRAINT IF EXISTS ch_range_discount;

ALTER TABLE person_discounts 
    ADD CONSTRAINT ch_range_discount 
    CHECK (discount BETWEEN 0 AND 100);


SELECT COUNT(*) = 4 AS check
FROM pg_constraint
WHERE conname IN (
    'ch_nn_person_id', 
    'ch_nn_pizzeria_id', 
    'ch_nn_discount', 
    'ch_range_discount'
);

SELECT column_default::INTEGER = 0 AS check
FROM information_schema.columns
WHERE column_name = 'discount' 
  AND table_name = 'person_discounts';