DROP TABLE IF EXISTS person_discounts;

CREATE TABLE person_discounts (
    id BIGINT PRIMARY KEY,
    person_id BIGINT,
    pizzeria_id BIGINT,
    discount NUMERIC,
    CONSTRAINT fk_person_discounts_person_id 
        FOREIGN KEY (person_id) REFERENCES person(id),
    CONSTRAINT fk_person_discounts_pizzeria_id 
        FOREIGN KEY (pizzeria_id) REFERENCES pizzeria(id)
);

SELECT COUNT(*) = 1 AS check
FROM pg_tables
WHERE tablename = 'person_discounts';