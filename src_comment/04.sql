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





















-- Удаляем ограничение ch_nn_person_id, если оно существует
-- ALTER TABLE - команда изменения структуры существующей таблицы
-- DROP CONSTRAINT - удаляет ограничение (constraint)
-- IF EXISTS - предотвращает ошибку, если ограничения нет
-- Это обеспечивает идемпотентность (можно запускать скрипт многократно)
ALTER TABLE person_discounts 
    DROP CONSTRAINT IF EXISTS ch_nn_person_id;

-- Добавляем ограничение ch_nn_person_id
-- ADD CONSTRAINT - добавляет новое ограничение
-- ch_nn_person_id - имя ограничения (ch = check, nn = not null)
-- CHECK (person_id IS NOT NULL) - проверяет, что person_id не пустой (не NULL)
-- IS NOT NULL - условие "значение существует"
-- Это запрещает вставлять строки без указания person_id
ALTER TABLE person_discounts 
    ADD CONSTRAINT ch_nn_person_id 
    CHECK (person_id IS NOT NULL);


-- Удаляем ограничение ch_nn_pizzeria_id, если оно существует
-- Аналогично первому блоку, но для столбца pizzeria_id
ALTER TABLE person_discounts 
    DROP CONSTRAINT IF EXISTS ch_nn_pizzeria_id;

-- Добавляем ограничение ch_nn_pizzeria_id
-- Запрещает вставлять строки без указания pizzeria_id
-- Гарантирует, что каждая скидка привязана к конкретной пиццерии
ALTER TABLE person_discounts 
    ADD CONSTRAINT ch_nn_pizzeria_id 
    CHECK (pizzeria_id IS NOT NULL);


-- Удаляем ограничение ch_nn_discount, если оно существует
ALTER TABLE person_discounts 
    DROP CONSTRAINT IF EXISTS ch_nn_discount;

-- Добавляем ограничение ch_nn_discount
-- Запрещает вставлять строки без указания discount
-- Гарантирует, что у каждой записи есть значение скидки (не NULL)
ALTER TABLE person_discounts 
    ADD CONSTRAINT ch_nn_discount 
    CHECK (discount IS NOT NULL);


-- Устанавливаем значение по умолчанию для столбца discount
-- ALTER COLUMN - изменяет параметры столбца
-- SET DEFAULT 0 - устанавливает значение по умолчанию = 0
-- Если при INSERT не указан discount, будет автоматически 0
-- Это удобно: INSERT INTO person_discounts (person_id, pizzeria_id) VALUES (1, 5);
-- discount автоматически станет 0
ALTER TABLE person_discounts 
    ALTER COLUMN discount SET DEFAULT 0;


-- Удаляем ограничение ch_range_discount, если оно существует
ALTER TABLE person_discounts 
    DROP CONSTRAINT IF EXISTS ch_range_discount;

-- Добавляем ограничение ch_range_discount
-- ch_range_discount - имя ограничения (range = диапазон)
-- CHECK (discount BETWEEN 0 AND 100) - проверяет диапазон значений
-- BETWEEN 0 AND 100 - эквивалентно (discount >= 0 AND discount <= 100)
-- Скидка не может быть отрицательной или больше 100%
-- Запрещает вставку некорректных значений типа -10 или 150
ALTER TABLE person_discounts 
    ADD CONSTRAINT ch_range_discount 
    CHECK (discount BETWEEN 0 AND 100);


-- Проверка успешности создания ограничений
-- SELECT COUNT(*) = 4 - проверяем, что создано ровно 4 ограничения
-- AS check - называем результат "check"
SELECT COUNT(*) = 4 AS check
-- FROM pg_constraint - системная таблица PostgreSQL, содержащая все ограничения
FROM pg_constraint
-- WHERE conname IN (...) - фильтр по именам ограничений
-- conname - название столбца в pg_constraint, хранящего имя ограничения
-- Проверяем наличие всех 4 ограничений, которые мы создали
WHERE conname IN (
    'ch_nn_person_id',      -- NOT NULL для person_id
    'ch_nn_pizzeria_id',    -- NOT NULL для pizzeria_id
    'ch_nn_discount',       -- NOT NULL для discount
    'ch_range_discount'     -- диапазон 0-100 для discount
);
-- Ожидаемый результат: true (найдено 4 ограничения)

-- Проверка значения по умолчанию для столбца discount
-- SELECT column_default::INTEGER = 0 - проверяем, что DEFAULT = 0
-- column_default - значение по умолчанию в виде текста
-- ::INTEGER - приводим текст к целому числу для сравнения
SELECT column_default::INTEGER = 0 AS check
-- FROM information_schema.columns - системная таблица с информацией о столбцах
FROM information_schema.columns
-- WHERE - фильтр для поиска нужного столбца
WHERE column_name = 'discount'       -- ищем столбец discount
  AND table_name = 'person_discounts';  -- в таблице person_discounts
-- Ожидаемый результат: true (DEFAULT = 0)
```

---

## КРАТКИЙ ПЕРЕСКАЗ ДЛЯ УСТНОЙ ЗАЩИТЫ:

**Блоки 1-3 (строки 1-22)**: Добавляю три CHECK constraint для проверки NOT NULL на столбцы person_id, pizzeria_id и discount. Каждый раз сначала удаляю старое ограничение (если есть) для идемпотентности, потом создаю новое.

**Строка 24-27**: Устанавливаю значение по умолчанию 0 для столбца discount. Теперь, если при вставке не указать скидку, она автоматически будет 0%.

**Строки 29-34**: Добавляю CHECK constraint для проверки диапазона — скидка должна быть от 0 до 100 процентов. Это защищает от ввода некорректных значений типа -10% или 200%.

**Строки 36-45**: Проверочный запрос к системной таблице pg_constraint — подтверждаю, что все 4 ограничения успешно созданы.

**Строки 47-51**: Проверочный запрос к information_schema.columns — подтверждаю, что DEFAULT значение для discount установлено в 0.

---

## ЧТО ТАКОЕ CONSTRAINT?

**Constraint** (ограничение) — это правило, которое проверяет данные при INSERT/UPDATE.

### Аналогия: Правила въезда в страну

Представь **границу страны**:

**CHECK constraint** = пограничник, который проверяет документы:
- ❌ "Паспорт просрочен" → не пропустит (CHECK failed)
- ❌ "Виза недействительна" → не пропустит
- ✓ "Все документы в порядке" → пропустит

### В базе данных:

```sql
CHECK (discount BETWEEN 0 AND 100)
```

PostgreSQL проверяет при каждой вставке:
- ❌ `discount = -10` → ОШИБКА! (меньше 0)
- ❌ `discount = 150` → ОШИБКА! (больше 100)
- ✓ `discount = 22.5` → OK (в диапазоне)

---

## ТИПЫ CONSTRAINT

| Тип | Что проверяет | Пример |
|-----|---------------|--------|
| **CHECK** | Условие истинно | `CHECK (age >= 18)` |
| **NOT NULL** | Значение не пустое | `person_id BIGINT NOT NULL` |
| **UNIQUE** | Значения уникальны | `UNIQUE (email)` |
| **PRIMARY KEY** | Уникальность + NOT NULL | `id BIGINT PRIMARY KEY` |
| **FOREIGN KEY** | Ссылка существует | `FOREIGN KEY (person_id) REFERENCES person(id)` |
| **DEFAULT** | Значение по умолчанию | `discount NUMERIC DEFAULT 0` |

---

## ПОЧЕМУ CHECK ВМЕСТО NOT NULL?

Можно было бы написать:

```sql
ALTER TABLE person_discounts 
    ALTER COLUMN person_id SET NOT NULL;
```

**НО** в задании требуется использовать **CHECK constraint** с именем.

### Разница:

**NOT NULL (встроенный):**
```sql
ALTER COLUMN person_id SET NOT NULL;
```
- Имя создается автоматически
- Нельзя задать свое имя

**CHECK (именованный):**
```sql
ADD CONSTRAINT ch_nn_person_id CHECK (person_id IS NOT NULL);
```
- Можно задать свое имя (ch_nn_person_id)
- Легче искать и удалять

**Результат одинаковый** — оба запрещают NULL.

---

## ЧТО ТАКОЕ DEFAULT?

**DEFAULT** — значение, которое вставляется автоматически, если не указано явно.

### БЕЗ DEFAULT:

```sql
INSERT INTO person_discounts (person_id, pizzeria_id) 
VALUES (1, 5);
```

❌ ОШИБКА! `discount не может быть NULL` (из-за CHECK constraint)

### С DEFAULT:

```sql
ALTER COLUMN discount SET DEFAULT 0;

INSERT INTO person_discounts (person_id, pizzeria_id) 
VALUES (1, 5);
```

✓ OK! PostgreSQL автоматически вставит `discount = 0`

Результат:
```
person_id | pizzeria_id | discount
----------|-------------|----------
1         | 5           | 0        ← автоматически!
```

---

## ЧТО ТАКОЕ BETWEEN?

**BETWEEN** — проверка диапазона (включительно с обоих концов).

```sql
CHECK (discount BETWEEN 0 AND 100)
```

Эквивалентно:
```sql
CHECK (discount >= 0 AND discount <= 100)
```

### Примеры:

| Значение | Результат | Почему |
|----------|-----------|--------|
| -5 | ❌ ОШИБКА | -5 < 0 |
| 0 | ✓ OK | 0 >= 0 AND 0 <= 100 |
| 50.5 | ✓ OK | 0 <= 50.5 <= 100 |
| 100 | ✓ OK | 100 <= 100 |
| 150 | ❌ ОШИБКА | 150 > 100 |

---

## ЧТО ТАКОЕ pg_constraint?

**pg_constraint** — системная таблица PostgreSQL, хранящая информацию обо всех ограничениях.

### Структура (упрощенно):

```
conname      | contype | conrelid  | ...
-------------|---------|-----------|----
pk_person    | p       | person    | ... (PRIMARY KEY)
fk_orders    | f       | orders    | ... (FOREIGN KEY)
ch_nn_age    | c       | person    | ... (CHECK)
```

**conname** — имя ограничения
**contype** — тип (p=PRIMARY KEY, f=FOREIGN KEY, c=CHECK, u=UNIQUE)
**conrelid** — таблица, к которой относится

### Наш запрос:

```sql
SELECT COUNT(*) = 4
FROM pg_constraint
WHERE conname IN ('ch_nn_person_id', 'ch_nn_pizzeria_id', ...);
```

Проверяет: "Есть ли в системной таблице 4 ограничения с этими именами?"

---

## ЧТО ТАКОЕ information_schema.columns?

**information_schema.columns** — системная таблица со всеми столбцами всех таблиц.

### Структура (упрощенно):

```
table_name       | column_name | data_type | column_default | ...
-----------------|-------------|-----------|----------------|----
person           | id          | bigint    | NULL           | ...
person           | name        | text      | NULL           | ...
person_discounts | discount    | numeric   | 0              | ...
```

### Наш запрос:

```sql
SELECT column_default::INTEGER = 0
FROM information_schema.columns
WHERE column_name = 'discount' 
  AND table_name = 'person_discounts';
```

Ищет столбец `discount` в таблице `person_discounts` и проверяет, что DEFAULT = 0.

**column_default** хранится как **текст** (например, `'0'`), поэтому нужно `::INTEGER` для сравнения.

---

## АЛЬТЕРНАТИВНЫЕ СПОСОБЫ РЕШЕНИЯ

### Способ 1: Через ALTER COLUMN SET NOT NULL (вместо CHECK)

```sql
-- Вместо CHECK constraint используем встроенный NOT NULL
ALTER TABLE person_discounts 
    ALTER COLUMN person_id SET NOT NULL;

ALTER TABLE person_discounts 
    ALTER COLUMN pizzeria_id SET NOT NULL;

ALTER TABLE person_discounts 
    ALTER COLUMN discount SET NOT NULL;

-- DEFAULT остается как в оригинале
ALTER TABLE person_discounts 
    ALTER COLUMN discount SET DEFAULT 0;

-- Диапазон все равно через CHECK
ALTER TABLE person_discounts 
    DROP CONSTRAINT IF EXISTS ch_range_discount;

ALTER TABLE person_discounts 
    ADD CONSTRAINT ch_range_discount 
    CHECK (discount BETWEEN 0 AND 100);

-- Проверка (будет только 1 constraint вместо 4)
SELECT COUNT(*) = 1 AS check
FROM pg_constraint
WHERE conname = 'ch_range_discount';

SELECT column_default::INTEGER = 0 AS check
FROM information_schema.columns
WHERE column_name = 'discount' 
  AND table_name = 'person_discounts';
```

**Плюсы:**
- Короче код
- NOT NULL встроен в столбец

**Минусы:**
- ❌ Не соответствует заданию (требуются именованные CHECK constraints)
- Нельзя задать свое имя для NOT NULL

---

### Способ 2: Все constraints одной командой

```sql
ALTER TABLE person_discounts 
    DROP CONSTRAINT IF EXISTS ch_nn_person_id,
    DROP CONSTRAINT IF EXISTS ch_nn_pizzeria_id,
    DROP CONSTRAINT IF EXISTS ch_nn_discount,
    DROP CONSTRAINT IF EXISTS ch_range_discount,
    ADD CONSTRAINT ch_nn_person_id CHECK (person_id IS NOT NULL),
    ADD CONSTRAINT ch_nn_pizzeria_id CHECK (pizzeria_id IS NOT NULL),
    ADD CONSTRAINT ch_nn_discount CHECK (discount IS NOT NULL),
    ADD CONSTRAINT ch_range_discount CHECK (discount BETWEEN 0 AND 100),
    ALTER COLUMN discount SET DEFAULT 0;

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
```

**Плюсы:**
- Одна команда вместо 10
- Быстрее выполняется

**Минусы:**
- Менее читаемо
- Сложнее отлаживать (если ошибка, непонятно где)

---

### Способ 3: С использованием DO блока (динамический SQL)

```sql
DO $$
BEGIN
    -- Массив имен constraints
    DECLARE
        constraints TEXT[] := ARRAY[
            'ch_nn_person_id',
            'ch_nn_pizzeria_id',
            'ch_nn_discount',
            'ch_range_discount'
        ];
        constraint_name TEXT;
    BEGIN
        -- Удаляем все constraints
        FOREACH constraint_name IN ARRAY constraints
        LOOP
            EXECUTE format('ALTER TABLE person_discounts DROP CONSTRAINT IF EXISTS %I', constraint_name);
        END LOOP;
        
        -- Добавляем constraints
        ALTER TABLE person_discounts 
            ADD CONSTRAINT ch_nn_person_id CHECK (person_id IS NOT NULL),
            ADD CONSTRAINT ch_nn_pizzeria_id CHECK (pizzeria_id IS NOT NULL),
            ADD CONSTRAINT ch_nn_discount CHECK (discount IS NOT NULL),
            ADD CONSTRAINT ch_range_discount CHECK (discount BETWEEN 0 AND 100),
            ALTER COLUMN discount SET DEFAULT 0;
    END;
END $$;

-- Проверки остаются такими же
```

**DO блок** — анонимная функция PL/pgSQL для выполнения сложной логики

**Минусы:**
- Слишком сложно для простой задачи
- ❌ НЕ РЕКОМЕНДУЕТСЯ

---

### Способ 4: С проверкой существования таблицы

```sql
DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_tables WHERE tablename = 'person_discounts') THEN
        ALTER TABLE person_discounts 
            DROP CONSTRAINT IF EXISTS ch_nn_person_id;
        ALTER TABLE person_discounts 
            ADD CONSTRAINT ch_nn_person_id 
            CHECK (person_id IS NOT NULL);
        
        -- ... остальные constraints
    ELSE
        RAISE EXCEPTION 'Table person_discounts does not exist';
    END IF;
END $$;
```

**Плюсы:**
- Безопасно (проверяет существование таблицы)

**Минусы:**
- Избыточно (ALTER TABLE IF EXISTS уже есть)

---

### Способ 5: С созданием функции-валидатора

```sql
-- Создаем функцию для проверки скидки
CREATE OR REPLACE FUNCTION validate_discount(disc NUMERIC)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN disc IS NOT NULL AND disc BETWEEN 0 AND 100;
END;
$$ LANGUAGE plpgsql;

ALTER TABLE person_discounts 
    DROP CONSTRAINT IF EXISTS ch_valid_discount;

ALTER TABLE person_discounts 
    ADD CONSTRAINT ch_valid_discount 
    CHECK (validate_discount(discount));

-- Остальные constraints как в оригинале
```

**Плюсы:**
- Переиспользуемая логика
- Сложные проверки в одном месте

**Минусы:**
- Слишком сложно для простой проверки
- Медленнее (вызов функции)

---

### Способ 6: С DEFAULT в момент добавления столбца

Если бы мы создавали таблицу заново:

```sql
CREATE TABLE person_discounts (
    id BIGINT PRIMARY KEY,
    person_id BIGINT NOT NULL,
    pizzeria_id BIGINT NOT NULL,
    discount NUMERIC DEFAULT 0 NOT NULL CHECK (discount BETWEEN 0 AND 100)
);
```

**Плюсы:**
- Все в одном месте
- Короче

**Минусы:**
- В задании таблица УЖЕ создана, нужно изменять

---

### Способ 7: Комбинация DEFAULT и CHECK в одной команде

```sql
ALTER TABLE person_discounts 
    ALTER COLUMN discount SET DEFAULT 0,
    ALTER COLUMN discount SET NOT NULL,
    DROP CONSTRAINT IF EXISTS ch_range_discount,
    ADD CONSTRAINT ch_range_discount CHECK (discount BETWEEN 0 AND 100);
```

❌ **НЕ РАБОТАЕТ!** В PostgreSQL нельзя смешивать `ALTER COLUMN` и `ADD CONSTRAINT` в одной команде.

---

## СРАВНЕНИЕ СПОСОБОВ

| Способ | Сложность | Соответствие заданию | Читаемость | Рекомендация |
|--------|-----------|---------------------|------------|--------------|
| **Оригинал (CHECK constraints)** | Низкая | ✓ Полное | Отличная | ✓ Лучший |
| **SET NOT NULL** | Низкая | ✗ Нет именованных CHECK | Отличная | Не подходит |
| **Одна команда** | Средняя | ✓ Полное | Средняя | Компактнее |
| **DO блок** | Высокая | ✓ Полное | Плохая | Избыточно |
| **С проверкой таблицы** | Высокая | ✓ Полное | Средняя | Избыточно |
| **Функция-валидатор** | Высокая | ✓ Полное | Средняя | Избыточно |
| **В CREATE TABLE** | Низкая | - | Отличная | Для новых таблиц |

---

## РЕКОМЕНДАЦИЯ ДЛЯ ЗАЩИТЫ

**Оригинальный способ — правильный выбор**, потому что:
1. Соответствует требованиям (именованные CHECK constraints)
2. Понятная структура (каждое ограничение отдельно)
3. Легко читать и отлаживать
4. Идемпотентный (можно запускать многократно)

**Если спросят "почему CHECK вместо NOT NULL?":**
> "Задание требует именованные CHECK constraints. ALTER COLUMN SET NOT NULL создает ограничение с автоматическим именем, которое нельзя задать вручную. CHECK (person_id IS NOT NULL) дает тот же результат, но позволяет указать свое имя ch_nn_person_id по шаблону задания."

**Если спросят "почему DEFAULT отдельно?":**
> "DEFAULT — это не constraint, это свойство столбца. Его устанавливают через ALTER COLUMN SET DEFAULT, а не через ADD CONSTRAINT. DEFAULT и CHECK работают вместе: DEFAULT вставляет 0, если значение не указано, а CHECK проверяет, что значение в диапазоне 0-100."

**Если спросят "что делают проверочные запросы?":**
> "Первый запрос проверяет системную таблицу pg_constraint — подтверждает, что все 4 именованных ограничения успешно созданы. Второй запрос проверяет information_schema.columns — подтверждает, что DEFAULT значение для discount установлено в 0. Это автоматические тесты корректности выполнения скрипта."



























## ВОПРОС 1: Зачем приводить к INTEGER и зачем сравнивать?

### Проблема: column_default хранится как ТЕКСТ

```sql
column_default::INTEGER = 0
```

**column_default** в системной таблице `information_schema.columns` — это **ТЕКСТОВЫЙ** столбец, а не числовой.

### Что находится в column_default?

Когда мы делаем:
```sql
ALTER TABLE person_discounts ALTER COLUMN discount SET DEFAULT 0;
```

PostgreSQL сохраняет в `column_default` **текст**:
```
column_default = '0'   ← это строка (текст), не число!
```

### Если не приводить к INTEGER:

```sql
SELECT column_default = 0  -- ОШИБКА или FALSE!
```

**Почему?**
```
'0' = 0   ← текст '0' НЕ равен числу 0
```

Это как:
```
"пять" = 5  ← слово "пять" не равно цифре 5
```

### С приведением к INTEGER:

```sql
SELECT column_default::INTEGER = 0  -- OK!
       ↓
  '0'::INTEGER = 0
       ↓
      0 = 0   ← TRUE!
```

**::INTEGER** превращает текст `'0'` в число `0`.

---

### Зачем сравнивать (= 0)?

Чтобы получить **TRUE/FALSE** — результат теста.

**БЕЗ сравнения:**
```sql
SELECT column_default::INTEGER
FROM information_schema.columns
WHERE column_name = 'discount';
```

Результат:
```
column_default
--------------
0
```

Просто число 0. Непонятно — это хорошо или плохо? Нужно **вручную** проверять.

**С сравнением:**
```sql
SELECT column_default::INTEGER = 0 AS check
```

Результат:
```
check
-----
true
```

**true** = тест пройден! DEFAULT действительно равен 0.
**false** = тест НЕ пройден! DEFAULT не равен 0.

Это **автоматический тест** — сразу видно: работает или нет.

---

### Аналогия: Термометр

**БЕЗ сравнения:**
```
Температура: 36.6°C
```
Хорошо это или плохо? Нужно знать норму и сравнивать вручную.

**С сравнением:**
```
Температура нормальная? ✓ ДА
```
Сразу понятно — все в порядке!

---

## ВОПРОС 2: Зачем две проверки?

### Они проверяют РАЗНЫЕ вещи!

```sql
-- ПРОВЕРКА 1: Проверяет CONSTRAINTS (ограничения)
SELECT COUNT(*) = 4 AS check
FROM pg_constraint
WHERE conname IN ('ch_nn_person_id', 'ch_nn_pizzeria_id', ...);

-- ПРОВЕРКА 2: Проверяет DEFAULT (значение по умолчанию)
SELECT column_default::INTEGER = 0 AS check
FROM information_schema.columns
WHERE column_name = 'discount';
```

### DEFAULT ≠ CONSTRAINT!

**DEFAULT** — это **свойство столбца** (как цвет стен в комнате)
**CONSTRAINT** — это **правило** (как замок на двери)

Они **независимы** друг от друга!

---

### Аналогия: Квартира

**CONSTRAINT** = замки на дверях и окнах (защита от проникновения):
- ch_nn_person_id = замок на входной двери
- ch_nn_pizzeria_id = замок на балконной двери
- ch_nn_discount = замок на окне
- ch_range_discount = сигнализация (от 0 до 100)

**DEFAULT** = мебель в квартире (что там по умолчанию):
- discount DEFAULT 0 = в гостиной стоит диван

**Вопрос:** "Квартира защищена?"
- Проверка 1: Все 4 замка установлены? ✓
- Проверка 2: Диван в гостиной есть? ✓

Это **РАЗНЫЕ** проверки!

---

### Что проверяет каждая:

**ПРОВЕРКА 1 (pg_constraint):**
Проверяет **ПРАВИЛА**:
- ✓ Нельзя вставить NULL в person_id? (ch_nn_person_id)
- ✓ Нельзя вставить NULL в pizzeria_id? (ch_nn_pizzeria_id)
- ✓ Нельзя вставить NULL в discount? (ch_nn_discount)
- ✓ Нельзя вставить discount < 0 или > 100? (ch_range_discount)

**ПРОВЕРКА 2 (information_schema.columns):**
Проверяет **АВТОЗАПОЛНЕНИЕ**:
- ✓ Если не указать discount при INSERT, вставится 0?

---

### Пример: Почему обе нужны

#### Ситуация 1: Есть DEFAULT, НЕТ constraint

```sql
ALTER TABLE person_discounts ALTER COLUMN discount SET DEFAULT 0;
-- НО забыли добавить ch_range_discount!
```

**Проблема:**
```sql
INSERT INTO person_discounts (person_id, pizzeria_id, discount) 
VALUES (1, 5, 999);  -- ✓ ВСТАВИТСЯ! (нет проверки диапазона)
```

**ПРОВЕРКА 1:** ❌ FALSE (constraint нет)
**ПРОВЕРКА 2:** ✓ TRUE (DEFAULT есть)

Обе проверки нужны — вторая прошла, но первая показала проблему!

---

#### Ситуация 2: Есть constraint, НЕТ DEFAULT

```sql
ADD CONSTRAINT ch_range_discount CHECK (discount BETWEEN 0 AND 100);
-- НО забыли SET DEFAULT 0!
```

**Проблема:**
```sql
INSERT INTO person_discounts (person_id, pizzeria_id) 
VALUES (1, 5);  -- ❌ ОШИБКА! discount = NULL (нет DEFAULT)
```

**ПРОВЕРКА 1:** ✓ TRUE (constraint есть)
**ПРОВЕРКА 2:** ❌ FALSE (DEFAULT нет)

Обе проверки нужны — первая прошла, но вторая показала проблему!

---

### Что хранится где?

**pg_constraint** — хранит **ПРАВИЛА** (constraints):
```
conname           | contype | ...
------------------|---------|----
ch_nn_person_id   | c       | ... (CHECK constraint)
ch_nn_pizzeria_id | c       | ... (CHECK constraint)
ch_nn_discount    | c       | ... (CHECK constraint)
ch_range_discount | c       | ... (CHECK constraint)
```

**information_schema.columns** — хранит **СВОЙСТВА СТОЛБЦОВ**:
```
column_name | data_type | column_default | is_nullable | ...
------------|-----------|----------------|-------------|----
id          | bigint    | NULL           | NO          | ...
person_id   | bigint    | NULL           | YES         | ...
discount    | numeric   | 0              | YES         | ...
```

**DEFAULT живет в другой таблице!** Поэтому нужна отдельная проверка.

---

## КОРОТКИЙ ОТВЕТ

### Вопрос 1: Зачем приводить к INTEGER и зачем сравнивать?

**::INTEGER** — потому что `column_default` хранится как **ТЕКСТ** `'0'`, а не как число `0`. Нужно превратить текст в число для сравнения.

**= 0** — чтобы получить **TRUE/FALSE** как результат автоматического теста. TRUE = DEFAULT правильный (равен 0), FALSE = что-то не так.

---

### Вопрос 2: Зачем две проверки?

Они проверяют **РАЗНЫЕ** вещи:

**ПРОВЕРКА 1:**
Все 4 **CONSTRAINT** (правила) созданы?
- ch_nn_person_id
- ch_nn_pizzeria_id
- ch_nn_discount
- ch_range_discount

**ПРОВЕРКА 2:**
**DEFAULT** значение установлено в 0?

DEFAULT — это **НЕ constraint**, это свойство столбца. Они **независимы**.

**Аналогия:**
- Проверка 1 = "Все замки установлены?" ✓
- Проверка 2 = "Мебель расставлена?" ✓

Обе нужны, потому что проверяют разные вещи!

Понятно теперь?












































## ПОЧЕМУ column_default ХРАНИТСЯ КАК ТЕКСТ?

Потому что `column_default` должен **хранить ЛЮБЫЕ типы** значений для **РАЗНЫХ столбцов**.

### Проблема: Разные столбцы — разные типы DEFAULT

Представь таблицу:

```sql
CREATE TABLE example (
    id BIGINT DEFAULT 1,                          -- число
    name TEXT DEFAULT 'Unknown',                  -- строка
    created_at TIMESTAMP DEFAULT NOW(),           -- функция
    price NUMERIC DEFAULT 99.99,                  -- дробное число
    is_active BOOLEAN DEFAULT true,               -- логическое
    data JSONB DEFAULT '{"status": "new"}'::JSONB -- JSON
);
```

**У каждого столбца СВОЙ тип DEFAULT!**

### Если бы column_default был числом:

```sql
column_default BIGINT
```

❌ Не работает:
- Как хранить `'Unknown'`? (это текст, не число)
- Как хранить `NOW()`? (это функция, не число)
- Как хранить `true`? (это boolean, не число)

### Решение PostgreSQL: Хранить ВСЕ как ТЕКСТ

```sql
column_default TEXT
```

✓ Работает для всего:
```
column_name   | column_default
--------------|---------------------------
id            | '1'                     ← число как текст
name          | ''Unknown''::text'      ← строка
created_at    | 'now()'                 ← функция как текст
price         | '99.99'                 ← дробное как текст
is_active     | 'true'                  ← boolean как текст
data          | ''{"status":"new"}''::jsonb' ← JSON как текст
```

**Текст — универсальный формат!** Любое значение можно записать текстом.

---

## АНАЛОГИЯ: Коробка для разных вещей

Представь **склад** с коробками, где хранятся DEFAULT значения для каждого столбца.

### Вариант 1: Специализированные коробки (НЕ работает)

```
Коробка для чисел:     [1] [42] [99.99]
Коробка для строк:     ["Unknown"] ["Active"]
Коробка для дат:       [2024-01-01] [NOW()]
Коробка для boolean:   [true] [false]
```

**Проблема:** Нужно **много разных коробок** для каждого типа. Сложно!

### Вариант 2: Универсальные коробки (PostgreSQL так делает)

```
Одна коробка (текст): ["1"] ["Unknown"] ["NOW()"] ["99.99"] ["true"]
                        ↑      ↑          ↑          ↑         ↑
                     число   строка    функция   дробное   boolean
                   (как текст) (текст)  (текст)  (как текст) (текст)
```

**Решение:** Все хранится как **ТЕКСТ** в одной универсальной коробке. Просто!

---

## КАК ЭТО РАБОТАЕТ ВНУТРИ PostgreSQL?

### Шаг 1: Сохранение DEFAULT

Когда ты делаешь:
```sql
ALTER TABLE person_discounts ALTER COLUMN discount SET DEFAULT 0;
```

PostgreSQL:
1. Берет значение `0` (число)
2. Превращает в текст: `'0'`
3. Сохраняет в `information_schema.columns.column_default` как **текст**

### Шаг 2: Использование DEFAULT

Когда ты делаешь INSERT без указания discount:
```sql
INSERT INTO person_discounts (person_id, pizzeria_id) VALUES (1, 5);
```

PostgreSQL:
1. Смотрит в `column_default`: там текст `'0'`
2. Видит, что столбец discount типа NUMERIC
3. **Преобразует** текст `'0'` обратно в число `0`
4. Вставляет число `0` в таблицу

---

## ПРИМЕРЫ РАЗНЫХ DEFAULT В ВИДЕ ТЕКСТА

```sql
CREATE TABLE demo (
    -- Целое число
    count INT DEFAULT 42
);
```

В `column_default`:
```
'42'  ← текст, не число
```

---

```sql
CREATE TABLE demo (
    -- Строка
    status TEXT DEFAULT 'active'
);
```

В `column_default`:
```
'''active''::text'  ← строка с экранированными кавычками + ::text
```

**Двойные кавычки** — это способ PostgreSQL показать: "это была строка".

---

```sql
CREATE TABLE demo (
    -- Функция
    created_at TIMESTAMP DEFAULT NOW()
);
```

В `column_default`:
```
'now()'  ← текст "now()", не реальное время
```

При INSERT PostgreSQL **выполнит** эту функцию.

---

```sql
CREATE TABLE demo (
    -- Выражение
    total NUMERIC DEFAULT (price * quantity)
);
```

В `column_default`:
```
'(price * quantity)'  ← текст выражения
```

При INSERT PostgreSQL **вычислит** это выражение.

---

```sql
CREATE TABLE demo (
    -- NULL
    notes TEXT
);
```

В `column_default`:
```
NULL  ← специальное значение (не текст)
```

Если DEFAULT не установлен, `column_default` = NULL.

---

## ПОЧЕМУ ТЕКСТ — УНИВЕРСАЛЬНЫЙ ФОРМАТ?

**Текст** может представить **ЧТО УГОДНО**:

| Тип данных | Пример значения | Как текст |
|------------|-----------------|-----------|
| Число | 42 | `'42'` |
| Дробное | 99.99 | `'99.99'` |
| Строка | hello | `'''hello''::text'` |
| Boolean | true | `'true'` |
| Дата | 2024-01-01 | `'2024-01-01'` |
| Функция | NOW() | `'now()'` |
| JSON | {"key": "val"} | `''{"key":"val"}''::jsonb'` |
| NULL | NULL | `NULL` |

Любое значение **можно записать текстом**, а потом **превратить обратно** в нужный тип.

---

## ЗАЧЕМ ТОГДА ::INTEGER?

PostgreSQL хранит `'0'` (текст), но мы хотим **СРАВНИТЬ** с числом `0`.

### БЕЗ приведения типа:

```sql
SELECT column_default = 0;
       ↓
   '0' = 0   ← текст ≠ число
       ↓
    FALSE (или ОШИБКА)
```

### С приведением типа:

```sql
SELECT column_default::INTEGER = 0;
       ↓
   '0'::INTEGER = 0
       ↓
      0 = 0
       ↓
     TRUE
```

**::INTEGER** говорит PostgreSQL: "превращаю текст '0' в число 0".

---

## АНАЛОГИЯ: Книжная полка

Представь **библиотеку**, где на полке лежат **карточки** с информацией о книгах.

### На карточке написано (ТЕКСТОМ):

```
Название: "Война и мир"
Автор: "Толстой"
Год издания: "1869"        ← это ТЕКСТ на карточке, не число!
Страниц: "1225"             ← это тоже ТЕКСТ, не число!
В наличии: "да"             ← это ТЕКСТ, не boolean!
```

Все записано **ТЕКСТОМ** на карточке, потому что:
- Карточка — это **бумага** (как столбец в таблице)
- На бумаге можно писать только **ТЕКСТОМ**
- Но ты **понимаешь**, что "1869" — это год (число), а не просто буквы

Так же и PostgreSQL:
- Хранит `'0'` как **ТЕКСТ** в `column_default`
- Но **понимает**, что для столбца NUMERIC это **ЧИСЛО**
- При использовании **превращает** текст обратно в число

---

## ВНУТРЕННЕЕ УСТРОЙСТВО PostgreSQL

**information_schema** — это **VIEW** (представление), которое читает внутренние системные таблицы.

Настоящие данные хранятся в:
```sql
pg_catalog.pg_attrdef  -- реальная таблица с DEFAULT значениями
```

Структура (упрощенно):
```
adrelid  | adnum | adbin                    | adsrc
---------|-------|--------------------------|-------
table_id | col_# | <binary expression>      | '0'   ← текст!
```

**adsrc** (attribute default source) — исходный код DEFAULT **В ВИДЕ ТЕКСТА**.

PostgreSQL сохраняет DEFAULT как текст, чтобы:
1. Универсально хранить любые типы
2. Показывать человеку, что там написано
3. При необходимости **выполнить** этот текст (функции, выражения)

---

## КОРОТКИЙ ОТВЕТ

**column_default хранится как ТЕКСТ**, потому что:

1. **Универсальность** — текст может хранить что угодно:
   - Числа: `'0'`, `'42'`, `'99.99'`
   - Строки: `'''hello'''`
   - Функции: `'NOW()'`, `'UUID()'`
   - Boolean: `'true'`, `'false'`

2. **Один формат для всего** — не нужно создавать отдельные столбцы для каждого типа DEFAULT

3. **Гибкость** — можно хранить не только значения, но и **выражения** и **функции**

**Аналогия:** Как рецепт на бумаге — все записано текстом ("100 грамм", "2 яйца", "разогреть до 180°"), но при готовке ты **превращаешь** текст в реальные действия.

PostgreSQL делает то же: хранит `'0'` как текст, а при использовании **превращает** в реальное число `0`.

Понятно теперь?

