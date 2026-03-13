DROP INDEX IF EXISTS idx_menu_pizzeria_id;
CREATE INDEX idx_menu_pizzeria_id ON menu (pizzeria_id);

DROP INDEX IF EXISTS idx_person_order_person_id;
CREATE INDEX idx_person_order_person_id ON person_order (person_id);

DROP INDEX IF EXISTS idx_person_order_menu_id;
CREATE INDEX idx_person_order_menu_id ON person_order (menu_id);

DROP INDEX IF EXISTS idx_person_visits_person_id;
CREATE INDEX idx_person_visits_person_id ON person_visits (person_id);

DROP INDEX IF EXISTS idx_person_visits_pizzeria_id;
CREATE INDEX idx_person_visits_pizzeria_id ON person_visits (pizzeria_id);

SELECT COUNT(*) = 5 AS check
FROM pg_indexes
WHERE indexname IN (
    'idx_menu_pizzeria_id',
    'idx_person_order_person_id',
    'idx_person_order_menu_id',
    'idx_person_visits_person_id',
    'idx_person_visits_pizzeria_id'
);





-- Удаляем индекс idx_menu_pizzeria_id, если он существует (для идемпотентности)
DROP INDEX IF EXISTS idx_menu_pizzeria_id;
-- Создаём B-Tree индекс для внешнего ключа pizzeria_id в таблице menu
-- Ускоряет JOIN с таблицей pizzeria и поиск по pizzeria_id
CREATE INDEX idx_menu_pizzeria_id ON menu (pizzeria_id);

-- Удаляем индекс idx_person_order_person_id, если он существует
DROP INDEX IF EXISTS idx_person_order_person_id;
-- Создаём B-Tree индекс для внешнего ключа person_id в таблице person_order
-- Ускоряет JOIN с таблицей person и поиск заказов конкретного человека
CREATE INDEX idx_person_order_person_id ON person_order (person_id);

-- Удаляем индекс idx_person_order_menu_id, если он существует
DROP INDEX IF EXISTS idx_person_order_menu_id;
-- Создаём B-Tree индекс для внешнего ключа menu_id в таблице person_order
-- Ускоряет JOIN с таблицей menu и поиск заказов конкретной пиццы
CREATE INDEX idx_person_order_menu_id ON person_order (menu_id);

-- Удаляем индекс idx_person_visits_person_id, если он существует
DROP INDEX IF EXISTS idx_person_visits_person_id;
-- Создаём B-Tree индекс для внешнего ключа person_id в таблице person_visits
-- Ускоряет JOIN с таблицей person и поиск посещений конкретного человека
CREATE INDEX idx_person_visits_person_id ON person_visits (person_id);

-- Удаляем индекс idx_person_visits_pizzeria_id, если он существует
DROP INDEX IF EXISTS idx_person_visits_pizzeria_id;
-- Создаём B-Tree индекс для внешнего ключа pizzeria_id в таблице person_visits
-- Ускоряет JOIN с таблицей pizzeria и поиск посещений конкретной пиццерии
CREATE INDEX idx_person_visits_pizzeria_id ON person_visits (pizzeria_id);

-- Проверочный запрос: считаем количество созданных индексов в системном каталоге pg_indexes
-- Должно вернуть true, если все 5 индексов успешно созданы
SELECT COUNT(*) = 5 AS check
FROM pg_indexes
WHERE indexname IN (
    'idx_menu_pizzeria_id',
    'idx_person_order_person_id',
    'idx_person_order_menu_id',
    'idx_person_visits_person_id',
    'idx_person_visits_pizzeria_id'
);








##  Что такое Index Only Scan?

**Index Only Scan** = сканирование **ТОЛЬКО** индекса (без обращения к таблице)

### Аналогия - книга с оглавлением

**Обычный Index Scan (два шага):**

Задача: узнать на какой странице глава "Индексы" и сколько в ней страниц

Шаг 1: Смотришь в оглавление книги
       "Глава 5. Индексы .............. стр. 100"
       
Шаг 2: Открываешь страницу 100, смотришь сколько страниц в главе
       (нужно идти к САМОЙ КНИГЕ)


**Index Only Scan (один шаг):**

Задача: узнать на какой странице глава "Индексы" и сколько в ней страниц

Шаг 1: Смотришь в ПОДРОБНОЕ оглавление
       "Глава 5. Индексы .............. стр. 100-120 (20 страниц)"
       
Всё! Вся информация уже в оглавлении!
(НЕ нужно открывать книгу)


### В базе данных

**Обычный Index Scan:**

1. PostgreSQL читает индекс idx_person_order_multi
   → находит: "person_id=8, menu_id=19 находится в строке 3"
   
2. PostgreSQL идёт в таблицу person_order
   → читает строку 3
   → берёт данные: person_id=8, menu_id=19, order_date=2022-01-05

Итого: 2 операции чтения (индекс + таблица)


**Index Only Scan:**

1. PostgreSQL читает индекс idx_person_order_multi
   → индекс содержит: person_id=8, menu_id=19, order_date=2022-01-05
   → ВСЁ! Все нужные данные УЖЕ в индексе!

2. ~~Таблицу НЕ читаем~~

Итого: 1 операция чтения (только индекс) → в 2 раза быстрее!