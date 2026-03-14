DROP INDEX IF EXISTS idx_person_discounts_unique;

CREATE UNIQUE INDEX idx_person_discounts_unique 
    ON person_discounts(person_id, pizzeria_id);

SET enable_seqscan = OFF;

EXPLAIN ANALYSE
SELECT *
FROM person_discounts
WHERE person_id = 1 
  AND pizzeria_id = 12;















-- Удаляем индекс idx_person_discounts_unique, если он существует
-- IF EXISTS предотвращает ошибку, если индекса нет
-- Это обеспечивает идемпотентность (можно запускать скрипт многократно)
DROP INDEX IF EXISTS idx_person_discounts_unique;

-- Создаем уникальный индекс на таблице person_discounts
-- CREATE UNIQUE INDEX - создает индекс с проверкой уникальности
-- idx_person_discounts_unique - имя индекса (можно использовать для удаления/управления)
-- UNIQUE - гарантирует, что комбинация (person_id, pizzeria_id) уникальна
-- Это означает: один человек не может иметь две разные скидки в одной пиццерии
CREATE UNIQUE INDEX idx_person_discounts_unique 
    -- ON person_discounts - на какой таблице создаем индекс
    ON person_discounts(person_id, pizzeria_id);
    -- (person_id, pizzeria_id) - составной индекс по двум столбцам
    -- Порядок важен: сначала person_id, потом pizzeria_id

-- SET enable_seqscan = OFF - отключаем последовательное сканирование таблицы
-- enable_seqscan - параметр PostgreSQL, управляющий Sequential Scan (полный перебор строк)
-- OFF - запрещаем PostgreSQL читать таблицу построчно
-- Это ПРИНУЖДАЕТ PostgreSQL использовать индекс для демонстрации
-- В production так НЕ делают - это только для тестирования/демонстрации
SET enable_seqscan = OFF;

-- EXPLAIN ANALYSE - показывает план выполнения запроса и реальную статистику
-- EXPLAIN - показывает, КАК PostgreSQL будет выполнять запрос
-- ANALYSE (или ANALYZE) - РЕАЛЬНО выполняет запрос и показывает время/статистику
-- Это инструмент для оптимизации и проверки использования индексов
EXPLAIN ANALYSE
-- Основной запрос: выбрать все данные из person_discounts
SELECT *
FROM person_discounts
-- WHERE - условие фильтрации
-- person_id = 1 - ищем скидки для человека с id=1
WHERE person_id = 1 
  -- AND pizzeria_id = 12 - И для пиццерии с id=12
  -- Это ТОЧНО соответствует нашему индексу (person_id, pizzeria_id)
  -- PostgreSQL должен использовать индекс для быстрого поиска
  AND pizzeria_id = 12;
```

---

## КРАТКИЙ ПЕРЕСКАЗ ДЛЯ УСТНОЙ ЗАЩИТЫ:

**Строка 1-3**: Удаляю старый индекс, если он есть, чтобы скрипт можно было запускать повторно.

**Строка 5-9**: Создаю уникальный индекс на паре столбцов (person_id, pizzeria_id). UNIQUE гарантирует, что не будет дублей — один человек не может иметь две разные скидки в одной пиццерии.

**Строка 11-16**: Отключаю последовательное сканирование (seqscan), чтобы принудительно заставить PostgreSQL использовать индекс. Это только для демонстрации — в реальной работе так не делают.

**Строка 18-24**: EXPLAIN ANALYSE показывает план выполнения запроса и реальную статистику. Это проверка, что PostgreSQL действительно использует созданный индекс для поиска скидки конкретного человека в конкретной пиццерии.

---

## ЧТО ТАКОЕ ИНДЕКС?

**Индекс** — это вспомогательная структура данных для быстрого поиска.

### Аналогия: Библиотека

**БЕЗ индекса** (Sequential Scan):
- Ищешь книгу "Война и мир"
- Проходишь по ВСЕМ полкам подряд, читая название каждой книги
- Медленно! (особенно если 1 миллион книг)

**С индексом** (Index Scan):
- Смотришь в каталог (алфавитный указатель)
- Находишь: "Война и мир — полка 42, место 15"
- Идешь сразу туда
- Быстро!

### В базе данных:

**БЕЗ индекса:**
```
PostgreSQL перебирает ВСЕ строки таблицы:
строка 1: person_id=2? нет
строка 2: person_id=3? нет
строка 3: person_id=1? да! pizzeria_id=12? да! нашли!
строка 4: person_id=4? нет
...
строка 1000000: person_id=999? нет
```

**С индексом:**
```
PostgreSQL смотрит в индекс:
"person_id=1, pizzeria_id=12 → строка 3"
Сразу читает строку 3.
```

---

## ЧТО ТАКОЕ UNIQUE INDEX?

**UNIQUE INDEX** = индекс + проверка уникальности

Это два в одном:
1. **Ускоряет поиск** (как обычный индекс)
2. **Запрещает дубли** (как UNIQUE constraint)

### Пример:

```sql
INSERT INTO person_discounts (person_id, pizzeria_id, discount) 
VALUES (1, 12, 10);  -- ✓ OK

INSERT INTO person_discounts (person_id, pizzeria_id, discount) 
VALUES (1, 12, 20);  -- ❌ ОШИБКА! Пара (1, 12) уже есть!
```

PostgreSQL выдаст:
```
ERROR: duplicate key value violates unique constraint "idx_person_discounts_unique"
```

---

## ЧТО ТАКОЕ СОСТАВНОЙ ИНДЕКС?

**Составной индекс** (composite index) — индекс по **НЕСКОЛЬКИМ** столбцам.

```sql
CREATE INDEX idx_name ON table(column1, column2);
                                ↑        ↑
                            первый    второй
```

### Порядок столбцов ВАЖЕН!

```sql
CREATE INDEX idx_person_discounts_unique 
    ON person_discounts(person_id, pizzeria_id);
                        ↑          ↑
                     1-й приоритет  2-й приоритет
```

### Когда индекс используется:

✓ **WHERE person_id = 1** — используется (1-й столбец в индексе)
✓ **WHERE person_id = 1 AND pizzeria_id = 12** — используется (оба столбца)
✗ **WHERE pizzeria_id = 12** — НЕ используется эффективно (2-й столбец без 1-го)

### Аналогия: Телефонный справочник

Справочник отсортирован по: **Фамилия → Имя → Адрес**

✓ Найти "Иванов" — быстро (1-й уровень)
✓ Найти "Иванов Петр" — быстро (1-й + 2-й уровень)
✗ Найти всех "Петр" (без фамилии) — медленно (нужно читать весь справочник)

---

## ЧТО ДЕЛАЕТ SET enable_seqscan = OFF?

**enable_seqscan** — параметр PostgreSQL, разрешающий Sequential Scan (последовательное сканирование).

**Sequential Scan** (Seq Scan) — чтение таблицы построчно, как книгу от начала до конца.

### Зачем отключать?

Для **ДЕМОНСТРАЦИИ**, что индекс работает.

PostgreSQL сам решает, использовать индекс или нет, основываясь на статистике:
- Если таблица маленькая (10 строк) → Seq Scan быстрее
- Если таблица большая (1 млн строк) → Index Scan быстрее

**SET enable_seqscan = OFF** ПРИНУЖДАЕТ использовать индекс, даже если Seq Scan был бы быстрее.

### ⚠️ ВАЖНО:

**В production ТАК НЕ ДЕЛАЮТ!** Это только для тестирования.

После демонстрации нужно вернуть:
```sql
SET enable_seqscan = ON;
```

Или закрыть сессию (настройка действует только в текущей сессии).

---

## ЧТО ТАКОЕ EXPLAIN ANALYSE?

**EXPLAIN** — показывает **ПЛАН** выполнения запроса (что PostgreSQL собирается делать)
**ANALYSE** — **РЕАЛЬНО ВЫПОЛНЯЕТ** запрос и показывает статистику

### EXPLAIN (без ANALYSE):

```sql
EXPLAIN SELECT * FROM person_discounts WHERE person_id = 1;
```

Результат:
```
Index Scan using idx_person_discounts_unique on person_discounts
  Index Cond: (person_id = 1)
  (cost=0.15..8.17 rows=1 width=32)
```

**cost** — прогнозируемая стоимость (чем меньше, тем быстрее)
**rows** — прогнозируемое количество строк
**Запрос НЕ ВЫПОЛНЯЕТСЯ** — это только план

### EXPLAIN ANALYSE (с ANALYSE):

```sql
EXPLAIN ANALYSE SELECT * FROM person_discounts WHERE person_id = 1;
```

Результат:
```
Index Scan using idx_person_discounts_unique on person_discounts
  Index Cond: (person_id = 1)
  (cost=0.15..8.17 rows=1 width=32) 
  (actual time=0.023..0.025 rows=1 loops=1)
Planning Time: 0.104 ms
Execution Time: 0.042 ms
```

**actual time** — РЕАЛЬНОЕ время выполнения
**rows** — РЕАЛЬНОЕ количество найденных строк
**Запрос ВЫПОЛНЯЕТСЯ** — получаем точную статистику

---

## АЛЬТЕРНАТИВНЫЕ СПОСОБЫ РЕШЕНИЯ

### Способ 1: Обычный индекс (не уникальный)

```sql
DROP INDEX IF EXISTS idx_person_discounts_unique;

CREATE INDEX idx_person_discounts_person_pizzeria 
    ON person_discounts(person_id, pizzeria_id);

SET enable_seqscan = OFF;

EXPLAIN ANALYSE
SELECT *
FROM person_discounts
WHERE person_id = 1 
  AND pizzeria_id = 12;
```

**Разница:**
- **INDEX** вместо **UNIQUE INDEX**
- Разрешает дубли (одна пара может быть несколько раз)

**Минусы:**
- Не защищает от дублей
- Не соответствует требованиям задания

---

### Способ 2: Индекс в обратном порядке

```sql
DROP INDEX IF EXISTS idx_person_discounts_unique;

CREATE UNIQUE INDEX idx_person_discounts_unique 
    ON person_discounts(pizzeria_id, person_id);
    --                  ↑           ↑
    --              сначала пиццерия, потом человек

SET enable_seqscan = OFF;

EXPLAIN ANALYSE
SELECT *
FROM person_discounts
WHERE person_id = 1 
  AND pizzeria_id = 12;
```

**Разница:**
- Порядок столбцов: **(pizzeria_id, person_id)**

**Когда полезно:**
- Если часто ищем по pizzeria_id без person_id
- Например: "все скидки в пиццерии №5"

**В нашем случае:**
- Оба варианта работают для запроса с AND
- Но порядок **(person_id, pizzeria_id)** логичнее — обычно ищут "скидки человека"

---

### Способ 3: Два отдельных индекса

```sql
DROP INDEX IF EXISTS idx_person_discounts_unique;
DROP INDEX IF EXISTS idx_person_discounts_person_id;
DROP INDEX IF EXISTS idx_person_discounts_pizzeria_id;

-- Уникальность через UNIQUE CONSTRAINT
ALTER TABLE person_discounts
    ADD CONSTRAINT uq_person_pizzeria 
    UNIQUE (person_id, pizzeria_id);

-- Отдельные индексы для поиска
CREATE INDEX idx_person_discounts_person_id 
    ON person_discounts(person_id);

CREATE INDEX idx_person_discounts_pizzeria_id 
    ON person_discounts(pizzeria_id);

SET enable_seqscan = OFF;

EXPLAIN ANALYSE
SELECT *
FROM person_discounts
WHERE person_id = 1 
  AND pizzeria_id = 12;
```

**Разница:**
- UNIQUE CONSTRAINT вместо UNIQUE INDEX
- Два одноколоночных индекса вместо одного составного

**Минусы:**
- Занимает больше места (3 структуры вместо 1)
- Медленнее для запросов с AND

---

### Способ 4: С включением дополнительных столбцов (INCLUDE)

```sql
DROP INDEX IF EXISTS idx_person_discounts_unique;

CREATE UNIQUE INDEX idx_person_discounts_unique 
    ON person_discounts(person_id, pizzeria_id)
    INCLUDE (discount);

SET enable_seqscan = OFF;

EXPLAIN ANALYSE
SELECT *
FROM person_discounts
WHERE person_id = 1 
  AND pizzeria_id = 12;
```

**INCLUDE (discount)** — включает столбец discount в индекс (но не в ключ уникальности)

**Плюсы:**
- PostgreSQL может получить ВСЕ данные из индекса, не обращаясь к таблице (Index-Only Scan)
- Быстрее!

**Минусы:**
- Индекс занимает больше места

---

### Способ 5: С частичным индексом (Partial Index)

```sql
DROP INDEX IF EXISTS idx_person_discounts_unique;

CREATE UNIQUE INDEX idx_person_discounts_unique 
    ON person_discounts(person_id, pizzeria_id)
    WHERE discount > 0;

SET enable_seqscan = OFF;

EXPLAIN ANALYSE
SELECT *
FROM person_discounts
WHERE person_id = 1 
  AND pizzeria_id = 12
  AND discount > 0;
```

**WHERE discount > 0** — индекс включает ТОЛЬКО строки с discount > 0

**Плюсы:**
- Меньше размер индекса
- Быстрее для запросов с этим условием

**Минусы:**
- Не работает для запросов без условия discount > 0

---

### Способ 6: С использованием VERBOSE для детальной информации

```sql
DROP INDEX IF EXISTS idx_person_discounts_unique;

CREATE UNIQUE INDEX idx_person_discounts_unique 
    ON person_discounts(person_id, pizzeria_id);

SET enable_seqscan = OFF;

EXPLAIN (ANALYSE, VERBOSE, BUFFERS)
SELECT *
FROM person_discounts
WHERE person_id = 1 
  AND pizzeria_id = 12;
```

**VERBOSE** — показывает больше деталей (какие столбцы используются)
**BUFFERS** — показывает статистику по использованию памяти и диска

---

### Способ 7: Без SET enable_seqscan

```sql
DROP INDEX IF EXISTS idx_person_discounts_unique;

CREATE UNIQUE INDEX idx_person_discounts_unique 
    ON person_discounts(person_id, pizzeria_id);

-- НЕ отключаем seqscan - PostgreSQL сам решит
-- SET enable_seqscan = OFF; ← убрали

EXPLAIN ANALYSE
SELECT *
FROM person_discounts
WHERE person_id = 1 
  AND pizzeria_id = 12;
```

**Плюсы:**
- PostgreSQL сам выбирает оптимальный план
- Реалистичнее для production

**Минусы:**
- Может использовать Seq Scan на маленьких таблицах (не покажет работу индекса)

---

## СРАВНЕНИЕ СПОСОБОВ

| Способ | Уникальность | Скорость поиска | Размер индекса | Соответствие заданию |
|--------|--------------|-----------------|----------------|---------------------|
| **Оригинал (UNIQUE INDEX)** | ✓ | Высокая | Средний | ✓ Полное |
| **Обычный INDEX** | ✗ | Высокая | Средний | ✗ Нет уникальности |
| **Обратный порядок** | ✓ | Высокая | Средний | ✓ Полное |
| **Два индекса** | ✓ | Средняя | Большой | ✓ Избыточно |
| **С INCLUDE** | ✓ | Очень высокая | Большой | ✓ Оптимизированное |
| **Частичный** | ✓ | Очень высокая | Маленький | ✗ Только для части данных |
| **С VERBOSE** | ✓ | Высокая | Средний | ✓ Детальная диагностика |
| **Без SET** | ✓ | Зависит | Средний | ✓ Production-подход |

---

## РЕКОМЕНДАЦИЯ ДЛЯ ЗАЩИТЫ

**Оригинальный способ — правильный выбор**, потому что:
1. UNIQUE INDEX предотвращает дубли
2. Составной индекс ускоряет поиск по обоим столбцам
3. SET enable_seqscan = OFF демонстрирует использование индекса
4. EXPLAIN ANALYSE подтверждает работу индекса

**Если спросят "зачем SET enable_seqscan = OFF?":**
> "Это принудительное отключение последовательного сканирования для демонстрации работы индекса. На маленьких таблицах PostgreSQL может предпочесть Seq Scan как более быстрый. SET enable_seqscan = OFF заставляет использовать индекс для проверки. В production так не делают — PostgreSQL сам выбирает оптимальный план."

**Если спросят "что показывает EXPLAIN ANALYSE?":**
> "EXPLAIN ANALYSE показывает план выполнения запроса и реальную статистику. Основное — строка 'Index Scan using idx_person_discounts_unique' подтверждает, что PostgreSQL использует наш индекс для быстрого поиска, а не перебирает всю таблицу."

**Если спросят "почему UNIQUE INDEX, а не просто INDEX?":**
> "UNIQUE INDEX делает две вещи: ускоряет поиск И гарантирует уникальность пар (person_id, pizzeria_id). Это защищает от логической ошибки — один человек не может иметь две разные скидки в одной пиццерии."