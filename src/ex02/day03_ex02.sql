DROP INDEX IF EXISTS idx_person_name;
CREATE INDEX idx_person_name ON person (UPPER(name));

SET enable_seqscan = OFF;

EXPLAIN ANALYSE
SELECT *
FROM person
WHERE UPPER(name) = 'Kate';