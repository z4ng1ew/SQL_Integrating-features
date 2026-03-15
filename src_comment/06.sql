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







-- Удаляем последовательность seq_person_discounts, если она существует
-- DROP SEQUENCE - команда удаления последовательности (sequence)
-- IF EXISTS - предотвращает ошибку, если последовательности нет
-- CASCADE - удаляет также все зависимости (например, DEFAULT, использующие эту последовательность)
-- Это обеспечивает идемпотентность (можно запускать скрипт многократно)
DROP SEQUENCE IF EXISTS seq_person_discounts CASCADE;

-- Создаем новую последовательность (генератор уникальных номеров)
-- CREATE SEQUENCE - команда создания последовательности
-- seq_person_discounts - имя последовательности (по соглашению: seq_{table_name})
-- START 1 - начальное значение = 1 (первый id будет 1)
-- SEQUENCE - это объект БД, который генерирует уникальные числа: 1, 2, 3, 4...
-- Аналогия: нумератор страниц в книге (автоматически: страница 1, 2, 3...)
CREATE SEQUENCE seq_person_discounts 
    START 1;

-- Устанавливаем автоматическую генерацию id для таблицы person_discounts
-- ALTER TABLE person_discounts - изменяем таблицу
-- ALTER COLUMN id - изменяем столбец id
-- SET DEFAULT - устанавливаем значение по умолчанию
-- NEXTVAL('seq_person_discounts') - функция, возвращающая следующее значение из последовательности
-- NEXTVAL = NEXT VALUE = "следующее значение"
-- Теперь при INSERT без указания id он сгенерируется автоматически
ALTER TABLE person_discounts 
    ALTER COLUMN id SET DEFAULT NEXTVAL('seq_person_discounts');

-- Устанавливаем текущее значение последовательности
-- SELECT SETVAL - вызываем функцию установки значения последовательности
-- SETVAL(имя_последовательности, новое_значение) - устанавливает текущее значение
-- Это нужно, чтобы избежать конфликтов с уже существующими id
SELECT SETVAL(
    -- Первый параметр: имя последовательности
    'seq_person_discounts', 
    
    -- Второй параметр: новое значение = количество строк + 1
    -- (SELECT COUNT(*) + 1 FROM person_discounts) - подсчитываем строки в таблице
    -- COUNT(*) - количество существующих записей (например, 5)
    -- + 1 - следующий свободный номер (например, 6)
    -- Если в таблице 5 записей с id: 1,2,3,4,5, то SETVAL установит последовательность на 6
    -- Следующий INSERT получит id=6 (не будет конфликта с существующими)
    (SELECT COUNT(*) + 1 FROM person_discounts)
);
-- ВАЖНО: Если не установить текущее значение, последовательность начнет с 1,
-- но в таблице уже могут быть записи с id=1, что вызовет ошибку PRIMARY KEY violation


-- Проверка успешности создания и настройки последовательности
-- Выполняем три проверки одним запросом
SELECT 
    -- Проверка 1: Последовательность создана (найдена ровно 1 запись)
    -- COUNT(*) = 1 - проверяем, что последовательность существует
    COUNT(*) = 1 AS check1,
    
    -- Проверка 2: Начальное значение = 1
    -- MAX("start_value") - максимальное (в данном случае единственное) начальное значение
    -- "start_value" в кавычках, т.к. это системный столбец в pg_sequences
    -- = 1 - проверяем, что последовательность начинается с 1
    MAX("start_value") = 1 AS check2,
    
    -- Проверка 3: Текущее значение > 5
    -- MAX("last_value") - текущее значение последовательности (после SETVAL)
    -- > 5 - проверяем, что значение больше 5 (в таблице было минимум несколько записей)
    -- "last_value" - последнее выданное значение последовательности
    MAX("last_value") > 5 AS check3
    
-- FROM pg_sequences - системная таблица PostgreSQL со всеми последовательностями
FROM pg_sequences
-- WHERE sequencename = 'seq_person_discounts' - фильтр по имени последовательности
WHERE sequencename = 'seq_person_discounts';
-- Ожидаемый результат: check1=true, check2=true, check3=true
```

---

## КРАТКИЙ ПЕРЕСКАЗ ДЛЯ УСТНОЙ ЗАЩИТЫ:

**Строка 1-6**: Удаляю старую последовательность (если есть) с помощью CASCADE, чтобы удалить и все зависимости. Затем создаю новую последовательность seq_person_discounts со стартовым значением 1.

**Строки 8-11**: Устанавливаю для столбца id значение по умолчанию — следующее значение из последовательности через NEXTVAL. Теперь при INSERT без указания id он будет генерироваться автоматически.

**Строки 13-23**: Вызываю SETVAL, чтобы установить текущее значение последовательности = количество строк + 1. Это критически важно: если в таблице уже есть 5 записей с id от 1 до 5, последовательность должна начать с 6, иначе будет конфликт PRIMARY KEY.

**Строки 25-42**: Три проверки через системную таблицу pg_sequences: (1) последовательность существует, (2) стартовое значение = 1, (3) текущее значение больше 5 (подтверждает, что SETVAL отработал и учел существующие записи).

---

## ЧТО ТАКОЕ SEQUENCE?

**SEQUENCE** (последовательность) — это объект базы данных, который **генерирует уникальные числа**.

### Аналогия: Нумератор билетов

Представь **очередь в банке**:

**БЕЗ SEQUENCE (вручную):**
```
Клиент 1: "Какой мой номер?" 
Сотрудник: "Посмотрю... последний был 42... значит твой 43"
Клиент 2: "А мой?"
Сотрудник: "Посмотрю... теперь 43... значит твой 44"
```

Медленно, можно ошибиться!

**С SEQUENCE (автомат):**
```
Клиент 1: [нажимает кнопку] → билет №43
Клиент 2: [нажимает кнопку] → билет №44
Клиент 3: [нажимает кнопку] → билет №45
```

Быстро, без ошибок, автоматически!

### В базе данных:

```sql
CREATE SEQUENCE seq_person_discounts START 1;
```

PostgreSQL создает "нумератор":
- Текущее значение: 1
- При каждом вызове NEXTVAL: выдает следующее число (2, 3, 4...)

---

## КЛЮЧЕВЫЕ ФУНКЦИИ

### NEXTVAL — "дай следующий номер"

```sql
NEXTVAL('seq_person_discounts')
```

**Что делает:**
1. Берет текущее значение последовательности (например, 5)
2. Увеличивает на 1: 5 → 6
3. Возвращает новое значение: 6
4. Сохраняет новое текущее значение: теперь 6

**Аналогия:** Нажал кнопку нумератора → получил следующий номер.

### SETVAL — "установи текущий номер"

```sql
SETVAL('seq_person_discounts', 10)
```

**Что делает:**
- Устанавливает текущее значение = 10
- Следующий NEXTVAL вернет 11

**Аналогия:** Перемотал нумератор на номер 10 (следующий будет 11).

---

## ПОЧЕМУ SETVAL С COUNT(*) + 1?

### Проблема: Существующие id

Представь, в таблице уже есть записи:

```sql
SELECT * FROM person_discounts;

id | person_id | pizzeria_id | discount
---|-----------|-------------|----------
1  | 1         | 5           | 22
2  | 1         | 3           | 30
3  | 2         | 1           | 10.5
4  | 2         | 5           | 22
5  | 3         | 2           | 30
```

**5 записей**, id от 1 до 5.

### БЕЗ SETVAL (начинаем с 1):

```sql
CREATE SEQUENCE seq_person_discounts START 1;
-- Текущее значение = 1

INSERT INTO person_discounts (person_id, pizzeria_id, discount)
VALUES (4, 1, 15);
-- NEXTVAL вернет 1
-- Попытка вставить id=1

❌ ОШИБКА! id=1 уже существует! (PRIMARY KEY violation)
```

### С SETVAL (начинаем с 6):

```sql
CREATE SEQUENCE seq_person_discounts START 1;
SETVAL('seq_person_discounts', (SELECT COUNT(*) + 1 FROM person_discounts));
-- COUNT(*) = 5
-- 5 + 1 = 6
-- Текущее значение = 6

INSERT INTO person_discounts (person_id, pizzeria_id, discount)
VALUES (4, 1, 15);
-- NEXTVAL вернет 6
-- Вставляет id=6

✓ OK! id=6 свободен!
```

---

## ФОРМУЛА: COUNT(*) + 1

```sql
SETVAL('seq_person_discounts', (SELECT COUNT(*) + 1 FROM person_discounts))
          ↓                               ↓
    имя последовательности        следующий свободный номер
```

**COUNT(*)** = количество строк в таблице
**+ 1** = следующий свободный номер

**Примеры:**
- 0 строк → COUNT(*) = 0 → SETVAL(1) → следующий NEXTVAL = 1 ✓
- 5 строк → COUNT(*) = 5 → SETVAL(6) → следующий NEXTVAL = 6 ✓
- 100 строк → COUNT(*) = 100 → SETVAL(101) → следующий NEXTVAL = 101 ✓

---

## ЧТО ТАКОЕ CASCADE?

**CASCADE** — "каскадное удаление" = удалить объект **И** все его зависимости.

### Зависимости SEQUENCE:

Если столбец использует SEQUENCE:

```sql
ALTER COLUMN id SET DEFAULT NEXTVAL('seq_person_discounts');
                              ↓
                        эта связь = зависимость
```

### БЕЗ CASCADE:

```sql
DROP SEQUENCE seq_person_discounts;

❌ ОШИБКА! "cannot drop sequence because column id depends on it"
```

### С CASCADE:

```sql
DROP SEQUENCE seq_person_discounts CASCADE;

✓ OK!
- Удаляет последовательность
- Удаляет DEFAULT NEXTVAL(...) из столбца id
```

**Аналогия:** Сносишь дом → автоматически убираешь подключения к электричеству, воде, газу.

---

## ЧТО ТАКОЕ pg_sequences?

**pg_sequences** — системная таблица (представление) PostgreSQL со всеми последовательностями.

### Структура (упрощенно):

```
sequencename          | start_value | last_value | increment_by | ...
----------------------|-------------|------------|--------------|----
seq_person_discounts  | 1           | 6          | 1            | ...
seq_other             | 100         | 150        | 1            | ...
```

**sequencename** — имя последовательности
**start_value** — начальное значение (из CREATE SEQUENCE START ...)
**last_value** — последнее выданное значение (текущее)
**increment_by** — шаг увеличения (по умолчанию 1)

---

## АЛЬТЕРНАТИВНЫЕ СПОСОБЫ РЕШЕНИЯ

### Способ 1: SERIAL вместо SEQUENCE (короткий)

```sql
-- SERIAL автоматически создает SEQUENCE и DEFAULT
DROP TABLE IF EXISTS person_discounts CASCADE;

CREATE TABLE person_discounts (
    id BIGSERIAL PRIMARY KEY,  -- BIGSERIAL = BIGINT + SEQUENCE + DEFAULT
    person_id BIGINT,
    pizzeria_id BIGINT,
    discount NUMERIC
);

-- Проверка аналогична
SELECT 
    COUNT(*) = 1 AS check1,
    MAX("start_value") = 1 AS check2,
    MAX("last_value") > 0 AS check3
FROM pg_sequences
WHERE sequencename = 'person_discounts_id_seq';  -- автоматическое имя
```

**BIGSERIAL** — это сокращение для:
1. Создание BIGINT столбца
2. Создание SEQUENCE с автоматическим именем
3. Установка DEFAULT NEXTVAL(...)

**Плюсы:**
- Очень короткий код
- Все автоматически

**Минусы:**
- ❌ В задании таблица УЖЕ создана, нельзя пересоздавать
- Имя SEQUENCE автоматическое (нет контроля)

---

### Способ 2: IDENTITY вместо SEQUENCE (современный)

```sql
-- PostgreSQL 10+ поддерживает IDENTITY (стандарт SQL)
DROP TABLE IF EXISTS person_discounts CASCADE;

CREATE TABLE person_discounts (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    person_id BIGINT,
    pizzeria_id BIGINT,
    discount NUMERIC
);

-- Проверка
SELECT 
    COUNT(*) = 1 AS check1
FROM pg_sequences
WHERE sequencename LIKE 'person_discounts_id_seq%';
```

**GENERATED ALWAYS AS IDENTITY** — современный стандарт SQL (аналог SERIAL)

**Плюсы:**
- Стандарт SQL (переносимость между БД)
- Автоматическое управление

**Минусы:**
- ❌ В задании таблица уже создана
- PostgreSQL 10+ (не работает на старых версиях)

---

### Способ 3: С явным указанием INCREMENT

```sql
DROP SEQUENCE IF EXISTS seq_person_discounts CASCADE;

CREATE SEQUENCE seq_person_discounts 
    START 1
    INCREMENT BY 1           -- шаг увеличения (явно указываем)
    MINVALUE 1               -- минимальное значение
    MAXVALUE 9223372036854775807  -- максимальное (для BIGINT)
    CACHE 1                  -- кэш (сколько значений держать в памяти)
    NO CYCLE;                -- не циклить (не начинать с начала после максимума)

ALTER TABLE person_discounts 
    ALTER COLUMN id SET DEFAULT NEXTVAL('seq_person_discounts');

SELECT SETVAL(
    'seq_person_discounts', 
    (SELECT COALESCE(MAX(id), 0) + 1 FROM person_discounts)
);

SELECT 
    COUNT(*) = 1 AS check1,
    MAX("start_value") = 1 AS check2,
    MAX("last_value") > 5 AS check3
FROM pg_sequences
WHERE sequencename = 'seq_person_discounts';
```

**INCREMENT BY 1** — шаг (по умолчанию уже 1, но можно указать явно)
**MINVALUE/MAXVALUE** — диапазон
**CACHE** — сколько значений генерировать заранее (для производительности)
**NO CYCLE** — не начинать с начала после достижения максимума

**COALESCE(MAX(id), 0)** — находит максимальный существующий id (или 0, если таблица пустая)

**Плюсы:**
- Полный контроль над параметрами
- COALESCE(MAX(id), 0) точнее, чем COUNT(*) (учитывает удаленные id)

**Минусы:**
- Избыточно для простой задачи

---

### Способ 4: С проверкой существования таблицы

```sql
DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_tables WHERE tablename = 'person_discounts') THEN
        DROP SEQUENCE IF EXISTS seq_person_discounts CASCADE;
        
        CREATE SEQUENCE seq_person_discounts START 1;
        
        ALTER TABLE person_discounts 
            ALTER COLUMN id SET DEFAULT NEXTVAL('seq_person_discounts');
        
        PERFORM SETVAL(
            'seq_person_discounts', 
            (SELECT COUNT(*) + 1 FROM person_discounts)
        );
    ELSE
        RAISE EXCEPTION 'Table person_discounts does not exist';
    END IF;
END $$;

-- Проверка аналогична
```

**DO блок** — анонимная функция для сложной логики

**Минусы:**
- Слишком сложно
- ❌ НЕ РЕКОМЕНДУЕТСЯ

---

### Способ 5: С сохранением существующих DEFAULT

```sql
-- Сохраняем текущий DEFAULT (если есть)
DO $$
DECLARE
    current_default TEXT;
BEGIN
    SELECT column_default INTO current_default
    FROM information_schema.columns
    WHERE table_name = 'person_discounts' AND column_name = 'id';
    
    -- Если DEFAULT уже есть и это SEQUENCE, удаляем её
    IF current_default LIKE 'nextval%' THEN
        EXECUTE 'DROP SEQUENCE IF EXISTS ' || 
                regexp_replace(current_default, '^nextval\(''(.*)''.*', '\1') || 
                ' CASCADE';
    END IF;
    
    -- Создаем новую
    CREATE SEQUENCE seq_person_discounts START 1;
    ALTER TABLE person_discounts ALTER COLUMN id SET DEFAULT NEXTVAL('seq_person_discounts');
    PERFORM SETVAL('seq_person_discounts', (SELECT COUNT(*) + 1 FROM person_discounts));
END $$;
```

**Минусы:**
- Очень сложно
- ❌ НЕ РЕКОМЕНДУЕТСЯ

---

### Способ 6: С MAX(id) вместо COUNT(*)

```sql
DROP SEQUENCE IF EXISTS seq_person_discounts CASCADE;

CREATE SEQUENCE seq_person_discounts START 1;

ALTER TABLE person_discounts 
    ALTER COLUMN id SET DEFAULT NEXTVAL('seq_person_discounts');

-- Используем MAX(id) вместо COUNT(*)
SELECT SETVAL(
    'seq_person_discounts', 
    (SELECT COALESCE(MAX(id), 0) + 1 FROM person_discounts)
);

SELECT 
    COUNT(*) = 1 AS check1,
    MAX("start_value") = 1 AS check2,
    MAX("last_value") > 5 AS check3
FROM pg_sequences
WHERE sequencename = 'seq_person_discounts';
```

**MAX(id)** — находит максимальный существующий id
**COALESCE(..., 0)** — если таблица пустая (MAX = NULL), возвращает 0

**Разница COUNT(*) vs MAX(id):**

**Пример 1:** Таблица с id: 1, 2, 3, 4, 5
- COUNT(*) = 5 → SETVAL(6) ✓
- MAX(id) = 5 → SETVAL(6) ✓
- Одинаково!

**Пример 2:** Таблица с id: 1, 2, 5, 10, 15 (были удаления)
- COUNT(*) = 5 → SETVAL(6) ❌ Конфликт! id=10 уже есть!
- MAX(id) = 15 → SETVAL(16) ✓ Безопасно!

**Плюсы:**
- **MAX(id) ТОЧНЕЕ** при наличии удаленных записей

**Минусы:**
- В нашем случае записи не удалялись, поэтому COUNT(*) = MAX(id)

---

### Способ 7: С функцией для переиспользования

```sql
CREATE OR REPLACE FUNCTION reset_sequence(
    seq_name TEXT,
    table_name TEXT,
    column_name TEXT DEFAULT 'id'
) RETURNS VOID AS $$
BEGIN
    EXECUTE format(
        'SELECT SETVAL(%L, (SELECT COALESCE(MAX(%I), 0) + 1 FROM %I))',
        seq_name, column_name, table_name
    );
END;
$$ LANGUAGE plpgsql;

-- Использование
DROP SEQUENCE IF EXISTS seq_person_discounts CASCADE;
CREATE SEQUENCE seq_person_discounts START 1;
ALTER TABLE person_discounts ALTER COLUMN id SET DEFAULT NEXTVAL('seq_person_discounts');
SELECT reset_sequence('seq_person_discounts', 'person_discounts');

-- Проверка аналогична
```

**Плюсы:**
- Переиспользуемая функция
- Можно применять к любым таблицам

**Минусы:**
- Избыточно для одноразовой задачи

---

## СРАВНЕНИЕ СПОСОБОВ

| Способ | Сложность | Подходит для задания | Точность | Рекомендация |
|--------|-----------|---------------------|----------|--------------|
| **Оригинал (COUNT + 1)** | Низкая | ✓ Да | Достаточная | ✓ Лучший |
| **SERIAL** | Низкая | ✗ Требует пересоздания таблицы | Высокая | Для новых таблиц |
| **IDENTITY** | Низкая | ✗ Требует пересоздания таблицы | Высокая | PostgreSQL 10+ |
| **С параметрами** | Средняя | ✓ Да | Высокая | Для особых требований |
| **DO блок с проверкой** | Высокая | ✓ Да | Достаточная | Избыточно |
| **MAX(id)** | Низкая | ✓ Да | **Очень высокая** | ✓ Если были удаления |
| **Функция** | Высокая | ✓ Да | Высокая | Для переиспользования |

---

## РЕКОМЕНДАЦИЯ ДЛЯ ЗАЩИТЫ

**Оригинальный способ — правильный выбор**, потому что:
1. Соответствует требованиям задания
2. Работает с существующей таблицей
3. Простой и понятный
4. COUNT(*) + 1 корректно для последовательных id

**Если спросят "зачем SETVAL?":**
> "SETVAL устанавливает текущее значение последовательности на основе существующих данных в таблице. Если в таблице уже есть записи с id от 1 до 5, последовательность должна начать с 6, иначе при следующем INSERT будет конфликт PRIMARY KEY."

**Если спросят "почему COUNT(*) + 1, а не просто COUNT(*)?":**
> "COUNT(*) возвращает количество существующих записей. Если записей 5 (id: 1,2,3,4,5), то COUNT(*) = 5. Но следующий свободный id = 6, поэтому нужно COUNT(*) + 1. SETVAL устанавливает ТЕКУЩЕЕ значение, а NEXTVAL вернет текущее+1."

**Если спросят "что делает CASCADE?":**
> "CASCADE каскадно удаляет зависимости. Если последовательность используется в DEFAULT столбца, DROP SEQUENCE без CASCADE выдаст ошибку. С CASCADE PostgreSQL автоматически удалит и последовательность, и DEFAULT из столбца."

**Если спросят "почему проверка last_value > 5?":**
> "Это проверяет, что SETVAL отработал корректно. В тестовых данных минимум 5 записей, значит SETVAL установил значение минимум 6. Проверка last_value > 5 подтверждает, что последовательность учла существующие данные."






































## ЧТО ТАКОЕ SEQUENCE?

**SEQUENCE** (последовательность) — это **специальный объект** в PostgreSQL, который **автоматически генерирует уникальные числа**.

### Аналогия из жизни: Автомат с билетами

Представь **очередь в поликлинике**:

```
┌─────────────────┐
│  АВТОМАТ        │
│  С БИЛЕТАМИ     │
│                 │
│  Текущий номер: │
│      042        │
│                 │
│  [ВЗЯТЬ БИЛЕТ]  │
└─────────────────┘
```

Когда ты нажимаешь кнопку:
1. Автомат выдает билет с номером **042**
2. Внутри счетчик увеличивается: 042 → 043
3. Следующий человек получит билет **043**

**SEQUENCE — это такой же автомат в базе данных!**

---

## ГДЕ ХРАНЯТСЯ SEQUENCE?

SEQUENCE — это **отдельный объект** в базе данных, как таблица или индекс.

### Посмотреть все последовательности:

```sql
SELECT * FROM pg_sequences;
```

Результат:
```
schemaname | sequencename          | start_value | last_value | increment_by | ...
-----------|----------------------|-------------|------------|--------------|----
public     | seq_person_discounts | 1           | 6          | 1            | ...
public     | person_id_seq        | 1           | 100        | 1            | ...
```

**Где хранятся:**
- В схеме (по умолчанию `public`)
- Отдельно от таблиц
- Имеют свои названия

---

## СИНТАКСИС: СОЗДАНИЕ SEQUENCE

```sql
CREATE SEQUENCE имя_последовательности
    [START значение]
    [INCREMENT BY шаг]
    [MINVALUE минимум | NO MINVALUE]
    [MAXVALUE максимум | NO MAXVALUE]
    [CACHE количество]
    [CYCLE | NO CYCLE]
    [OWNED BY таблица.столбец];
```

**[ ]** означает "необязательный параметр"

---

### Параметры CREATE SEQUENCE:

#### 1. START — начальное значение

```sql
CREATE SEQUENCE seq_example START 1;
-- Первый вызов NEXTVAL вернет 1
```

```sql
CREATE SEQUENCE seq_example START 100;
-- Первый вызов NEXTVAL вернет 100
```

**По умолчанию:** START 1

---

#### 2. INCREMENT BY — шаг увеличения

```sql
CREATE SEQUENCE seq_example INCREMENT BY 1;
-- Номера: 1, 2, 3, 4, 5...
```

```sql
CREATE SEQUENCE seq_example INCREMENT BY 10;
-- Номера: 1, 11, 21, 31, 41...
```

```sql
CREATE SEQUENCE seq_example INCREMENT BY -1;
-- Номера: 1, 0, -1, -2, -3... (обратный отсчет!)
```

**По умолчанию:** INCREMENT BY 1

**Аналогия:** Шаг между этажами в лифте.

---

#### 3. MINVALUE / MAXVALUE — границы

```sql
CREATE SEQUENCE seq_example 
    MINVALUE 1 
    MAXVALUE 100;
-- Может генерировать только числа от 1 до 100
```

```sql
CREATE SEQUENCE seq_example 
    NO MINVALUE 
    NO MAXVALUE;
-- Нет ограничений (до пределов BIGINT)
```

**По умолчанию для INCREMENT BY 1:**
- MINVALUE 1
- MAXVALUE 9223372036854775807 (максимум для BIGINT)

**Аналогия:** Границы нумерации домов на улице (от 1 до 100).

---

#### 4. CACHE — кэш для производительности

```sql
CREATE SEQUENCE seq_example CACHE 1;
-- Генерирует по 1 числу за раз
```

```sql
CREATE SEQUENCE seq_example CACHE 20;
-- Генерирует сразу 20 чисел в память (быстрее)
```

**CACHE** — сколько номеров сгенерировать **заранее** и держать в памяти.

**По умолчанию:** CACHE 1

**Когда использовать:**
- CACHE 1 — максимальная точность (медленнее)
- CACHE 20-100 — высокая производительность (могут быть пропуски при сбое сервера)

---

#### 5. CYCLE / NO CYCLE — циклить или нет

```sql
CREATE SEQUENCE seq_example 
    START 1 
    MAXVALUE 10 
    CYCLE;
-- 1,2,3...10, потом снова 1,2,3...
```

```sql
CREATE SEQUENCE seq_example 
    START 1 
    MAXVALUE 10 
    NO CYCLE;
-- 1,2,3...10, потом ОШИБКА "sequence reached maximum"
```

**По умолчанию:** NO CYCLE

**Когда использовать:**
- CYCLE — для ограниченных циклических id (редко)
- NO CYCLE — обычно (не хотим повторяющихся id)

---

#### 6. OWNED BY — владелец

```sql
CREATE SEQUENCE seq_example OWNED BY person.id;
-- Последовательность "принадлежит" столбцу person.id
-- При удалении столбца удалится и последовательность
```

**По умолчанию:** OWNED BY NONE (независимая последовательность)

**Зачем:**
- Автоматическая очистка при удалении таблицы
- SERIAL/BIGSERIAL автоматически создают OWNED BY

---

## СИНТАКСИС: УДАЛЕНИЕ SEQUENCE

```sql
DROP SEQUENCE [IF EXISTS] имя_последовательности [CASCADE | RESTRICT];
```

### Параметры DROP SEQUENCE:

#### 1. IF EXISTS — безопасное удаление

```sql
DROP SEQUENCE seq_example;
-- ❌ ОШИБКА, если последовательности нет
```

```sql
DROP SEQUENCE IF EXISTS seq_example;
-- ✓ Удаляет, если есть; молча пропускает, если нет
```

---

#### 2. CASCADE — каскадное удаление

```sql
DROP SEQUENCE seq_example CASCADE;
-- Удаляет последовательность И все зависимости
```

**Что удаляется:**
- Сама последовательность
- DEFAULT NEXTVAL(...) из столбцов, которые её используют
- Другие объекты, зависящие от неё

**Аналогия:** Снести дом вместе со всеми коммуникациями (электричество, вода, газ).

---

#### 3. RESTRICT — защита от случайного удаления

```sql
DROP SEQUENCE seq_example RESTRICT;
-- ❌ ОШИБКА, если есть зависимости
```

**По умолчанию:** RESTRICT

**Когда использовать:**
- RESTRICT — безопасно (защита от ошибок)
- CASCADE — когда точно хочешь удалить всё

---

## СИНТАКСИС: ИЗМЕНЕНИЕ SEQUENCE

```sql
ALTER SEQUENCE имя_последовательности
    [RESTART [WITH значение]]
    [INCREMENT BY шаг]
    [MINVALUE минимум | NO MINVALUE]
    [MAXVALUE максимум | NO MAXVALUE]
    [CACHE количество]
    [CYCLE | NO CYCLE]
    [OWNED BY таблица.столбец];
```

### Примеры ALTER SEQUENCE:

#### 1. RESTART — сброс счетчика

```sql
ALTER SEQUENCE seq_example RESTART;
-- Сбрасывает к START значению
```

```sql
ALTER SEQUENCE seq_example RESTART WITH 1;
-- Сбрасывает к конкретному значению (1)
```

**Когда использовать:** Очистили таблицу, нужно начать с 1 снова.

---

#### 2. Изменение INCREMENT

```sql
ALTER SEQUENCE seq_example INCREMENT BY 5;
-- Теперь шаг = 5 (было 1)
```

---

#### 3. Изменение MAXVALUE

```sql
ALTER SEQUENCE seq_example MAXVALUE 1000;
-- Теперь максимум 1000 (было больше)
```

---

## ФУНКЦИИ ДЛЯ РАБОТЫ С SEQUENCE

### 1. NEXTVAL — "дай следующее значение"

```sql
NEXTVAL('имя_последовательности')
```

**Что делает:**
1. Берет текущее значение
2. Увеличивает на INCREMENT BY
3. Возвращает новое значение
4. Сохраняет его как текущее

**Пример:**

```sql
CREATE SEQUENCE seq_demo START 1;

SELECT NEXTVAL('seq_demo');  -- вернет 1
SELECT NEXTVAL('seq_demo');  -- вернет 2
SELECT NEXTVAL('seq_demo');  -- вернет 3
```

**Аналогия:** Нажать кнопку "взять билет" в очереди.

---

### 2. CURRVAL — "покажи текущее значение"

```sql
CURRVAL('имя_последовательности')
```

**Что делает:**
- Возвращает **последнее** значение, выданное NEXTVAL **в этой сессии**

**Пример:**

```sql
SELECT NEXTVAL('seq_demo');  -- 1
SELECT CURRVAL('seq_demo');  -- 1 (показывает последнее)
SELECT NEXTVAL('seq_demo');  -- 2
SELECT CURRVAL('seq_demo');  -- 2
```

**ВАЖНО:** CURRVAL не работает, пока не вызван NEXTVAL хотя бы раз!

```sql
SELECT CURRVAL('seq_demo');
-- ❌ ОШИБКА: "currval of sequence "seq_demo" is not yet defined in this session"
```

**Аналогия:** Посмотреть на свой билет (не брать новый).

---

### 3. SETVAL — "установи текущее значение"

```sql
SETVAL('имя_последовательности', новое_значение, [is_called])
```

**Что делает:**
- Устанавливает текущее значение вручную

**Параметры:**
- **новое_значение** — на что установить
- **is_called** (необязательно):
  - `true` (по умолчанию) — следующий NEXTVAL вернет значение+1
  - `false` — следующий NEXTVAL вернет само значение

**Пример 1 (is_called = true):**

```sql
SELECT SETVAL('seq_demo', 10);       -- устанавливает на 10
SELECT NEXTVAL('seq_demo');          -- вернет 11
```

**Пример 2 (is_called = false):**

```sql
SELECT SETVAL('seq_demo', 10, false);  -- устанавливает на 10
SELECT NEXTVAL('seq_demo');            -- вернет 10 (не 11!)
```

**Аналогия:** Перемотать нумератор на конкретный номер.

---

### 4. LASTVAL — "последнее значение из любой последовательности"

```sql
LASTVAL()
```

**Что делает:**
- Возвращает последнее значение из **ЛЮБОЙ** последовательности в этой сессии

**Пример:**

```sql
SELECT NEXTVAL('seq_demo');   -- 1
SELECT NEXTVAL('seq_other');  -- 5
SELECT LASTVAL();             -- 5 (последнее из всех)
```

**Редко используется** (обычно нужен конкретный CURRVAL).

---

## КАК SEQUENCE ИСПОЛЬЗУЕТСЯ С ТАБЛИЦАМИ

### Вариант 1: Вручную создать SEQUENCE и привязать

```sql
-- Шаг 1: Создать последовательность
CREATE SEQUENCE seq_person_id START 1;

-- Шаг 2: Создать таблицу
CREATE TABLE person (
    id BIGINT DEFAULT NEXTVAL('seq_person_id') PRIMARY KEY,
    name TEXT
);

-- Шаг 3: Использовать
INSERT INTO person (name) VALUES ('Вася');  -- id=1 автоматически
INSERT INTO person (name) VALUES ('Петя');  -- id=2 автоматически
```

---

### Вариант 2: SERIAL (автоматически создает SEQUENCE)

```sql
CREATE TABLE person (
    id SERIAL PRIMARY KEY,  -- автоматически создает seq + DEFAULT
    name TEXT
);
```

**SERIAL** автоматически делает:
1. Создает SEQUENCE с именем `person_id_seq`
2. Устанавливает DEFAULT NEXTVAL('person_id_seq')
3. Связывает OWNED BY person.id

**Эквивалентно:**

```sql
CREATE SEQUENCE person_id_seq OWNED BY person.id;
CREATE TABLE person (
    id INTEGER DEFAULT NEXTVAL('person_id_seq') PRIMARY KEY,
    name TEXT
);
```

---

### Вариант 3: BIGSERIAL (для больших чисел)

```sql
CREATE TABLE person (
    id BIGSERIAL PRIMARY KEY,  -- BIGINT + SEQUENCE
    name TEXT
);
```

**Типы SERIAL:**
- **SERIAL** = INTEGER (до 2 млрд)
- **BIGSERIAL** = BIGINT (до 9 квинтиллионов)
- **SMALLSERIAL** = SMALLINT (до 32 тысяч)

---

### Вариант 4: GENERATED ALWAYS AS IDENTITY (PostgreSQL 10+)

```sql
CREATE TABLE person (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT
);
```

**GENERATED ALWAYS** — современный стандарт SQL (заменяет SERIAL).

**Разница:**
- SERIAL — специфика PostgreSQL
- IDENTITY — стандарт SQL (работает в разных БД)

---

## КОГДА И ГДЕ ПРИМЕНЯТЬ SEQUENCE

### 1. Автоматическая генерация PRIMARY KEY

**Самое частое применение!**

```sql
CREATE SEQUENCE seq_orders START 1;

CREATE TABLE orders (
    id BIGINT DEFAULT NEXTVAL('seq_orders') PRIMARY KEY,
    customer_id BIGINT,
    total NUMERIC
);

INSERT INTO orders (customer_id, total) VALUES (1, 500);
-- id=1 автоматически
```

**Зачем:** Не нужно вручную придумывать id для каждого заказа.

---

### 2. Уникальные номера документов

```sql
CREATE SEQUENCE seq_invoice_number START 1000;

CREATE TABLE invoices (
    id BIGSERIAL PRIMARY KEY,
    invoice_number TEXT DEFAULT 'INV-' || NEXTVAL('seq_invoice_number'),
    amount NUMERIC
);

INSERT INTO invoices (amount) VALUES (1500);
-- invoice_number = 'INV-1000'

INSERT INTO invoices (amount) VALUES (2000);
-- invoice_number = 'INV-1001'
```

**Зачем:** Автоматическая нумерация счетов: INV-1000, INV-1001...

---

### 3. Версионирование

```sql
CREATE SEQUENCE seq_version START 1;

CREATE TABLE documents (
    id BIGSERIAL PRIMARY KEY,
    title TEXT,
    version INTEGER DEFAULT NEXTVAL('seq_version'),
    created_at TIMESTAMP DEFAULT NOW()
);
```

**Зачем:** Автоматическая версия документов: v1, v2, v3...

---

### 4. Партии (batches)

```sql
CREATE SEQUENCE seq_batch START 1;

CREATE TABLE products (
    id BIGSERIAL PRIMARY KEY,
    name TEXT,
    batch_number INTEGER DEFAULT NEXTVAL('seq_batch')
);
```

**Зачем:** Каждая партия товаров получает уникальный номер.

---

### 5. Временные идентификаторы

```sql
CREATE SEQUENCE seq_session START 1;

SELECT NEXTVAL('seq_session') AS session_id;  -- 1
SELECT NEXTVAL('seq_session') AS session_id;  -- 2
```

**Зачем:** Генерация уникальных ID для сессий, транзакций.

---

## РАСПРОСТРАНЕННЫЕ ПРОБЛЕМЫ И РЕШЕНИЯ

### Проблема 1: "sequence reached maximum value"

```sql
CREATE SEQUENCE seq_small MAXVALUE 10;

SELECT NEXTVAL('seq_small');  -- 1
SELECT NEXTVAL('seq_small');  -- 2
...
SELECT NEXTVAL('seq_small');  -- 10
SELECT NEXTVAL('seq_small');  -- ❌ ОШИБКА!
```

**Решение:**

```sql
ALTER SEQUENCE seq_small MAXVALUE 1000;
-- или
ALTER SEQUENCE seq_small NO MAXVALUE;
```

---

### Проблема 2: "duplicate key value violates unique constraint"

```sql
CREATE SEQUENCE seq_test START 1;
CREATE TABLE test (id BIGINT DEFAULT NEXTVAL('seq_test') PRIMARY KEY);

INSERT INTO test VALUES (5);  -- вставили вручную id=5
INSERT INTO test DEFAULT VALUES;  -- id=1 (из sequence)
INSERT INTO test DEFAULT VALUES;  -- id=2
INSERT INTO test DEFAULT VALUES;  -- id=3
INSERT INTO test DEFAULT VALUES;  -- id=4
INSERT INTO test DEFAULT VALUES;  -- id=5 ❌ ОШИБКА! id=5 уже есть!
```

**Решение:** Установить SEQUENCE после максимального id:

```sql
SELECT SETVAL('seq_test', (SELECT MAX(id) FROM test));
```

---

### Проблема 3: Пропуски в нумерации

```sql
BEGIN;
  SELECT NEXTVAL('seq_test');  -- 1
ROLLBACK;

SELECT NEXTVAL('seq_test');  -- 2 (не 1!)
```

**SEQUENCE НЕ откатывается при ROLLBACK!**

**Почему:** Для производительности (иначе параллельные транзакции блокировались бы).

**Это нормально!** Пропуски в id — не проблема.

---

## ПОЛНЫЙ ПРИМЕР: ПОШАГОВО

```sql
-- Шаг 1: Создаем последовательность
CREATE SEQUENCE seq_customers 
    START 1 
    INCREMENT BY 1 
    MINVALUE 1 
    MAXVALUE 9999999 
    CACHE 1 
    NO CYCLE;

-- Шаг 2: Создаем таблицу
CREATE TABLE customers (
    id BIGINT DEFAULT NEXTVAL('seq_customers') PRIMARY KEY,
    name TEXT,
    email TEXT
);

-- Шаг 3: Вставляем данные
INSERT INTO customers (name, email) VALUES ('Вася', 'vasya@mail.com');
-- id=1 автоматически

INSERT INTO customers (name, email) VALUES ('Петя', 'petya@mail.com');
-- id=2 автоматически

-- Шаг 4: Проверяем
SELECT * FROM customers;

id | name  | email
---|-------|----------------
1  | Вася  | vasya@mail.com
2  | Петя  | petya@mail.com

-- Шаг 5: Смотрим текущее значение
SELECT CURRVAL('seq_customers');  -- 2

-- Шаг 6: Устанавливаем значение вручную
SELECT SETVAL('seq_customers', 100);

-- Шаг 7: Следующая вставка
INSERT INTO customers (name, email) VALUES ('Коля', 'kolya@mail.com');
-- id=101

-- Шаг 8: Удаляем последовательность
DROP SEQUENCE seq_customers CASCADE;
-- Удаляет sequence и DEFAULT из таблицы
```

---

## КОРОТКИЙ ОТВЕТ

**SEQUENCE** — это **генератор уникальных чисел** в PostgreSQL.

### Основные команды:

```sql
-- Создать
CREATE SEQUENCE имя START значение;

-- Удалить
DROP SEQUENCE [IF EXISTS] имя [CASCADE];

-- Изменить
ALTER SEQUENCE имя RESTART [WITH значение];

-- Получить следующее значение
SELECT NEXTVAL('имя');

-- Установить текущее
SELECT SETVAL('имя', значение);
```

### Где применяется:
1. **Автоматическая генерация PRIMARY KEY** (самое частое)
2. Уникальные номера документов
3. Версионирование
4. Партии товаров
5. Любая автоматическая нумерация

### Аналогия:
**SEQUENCE = автомат с номерами в очереди**
- Нажал кнопку (NEXTVAL) → получил номер
- Номера не повторяются
- Автоматически увеличиваются

Понятно теперь?























































## КЛЮЧЕВОЕ ОТЛИЧИЕ

**ROW_NUMBER()** — это **одноразовая нумерация** в момент запроса (как нумерация страниц в распечатанном документе)

**SEQUENCE** — это **постоянный генератор** в базе данных (как нумератор билетов в очереди)

---

## АНАЛОГИЯ: Книга vs Автомат

### ROW_NUMBER() = Нумерация страниц при печати книги

```
Ты печатаешь книгу:
Страница 1: "Введение"
Страница 2: "Глава 1"
Страница 3: "Глава 2"

Распечатал → номера ЗАФИКСИРОВАНЫ
Удалил страницу 2 → номера НЕ ИЗМЕНЯТСЯ (1, 3)
Напечатал заново → НОВАЯ нумерация (1, 2)
```

**ROW_NUMBER():**
- Нумерует строки **В МОМЕНТ ЗАПРОСА**
- Каждый раз заново
- Не сохраняется в таблице

---

### SEQUENCE = Автомат с билетами в очереди

```
Автомат помнит:
"Последний выданный билет: №42"

Человек 1 нажимает → билет №43
Человек 2 нажимает → билет №44
Человек 1 уходит → автомат НЕ ЗАБЫВАЕТ (следующий = 45)
Завтра приходишь → автомат помнит (следующий = 45)
```

**SEQUENCE:**
- Хранит **ПОСТОЯННОЕ СОСТОЯНИЕ**
- Помнит последний выданный номер
- Не зависит от запросов

---

## ПРИМЕР 1: Вставка данных

### С ROW_NUMBER() (ОДНОРАЗОВО)

```sql
-- Вставка 1: Используем ROW_NUMBER()
INSERT INTO person_discounts (id, person_id, pizzeria_id, discount)
SELECT
    ROW_NUMBER() OVER () AS id,  -- генерирует: 1, 2, 3
    person_id,
    pizzeria_id,
    discount
FROM temp_data;

-- Результат в таблице:
id | person_id | ...
---|-----------|----
1  | 10        | ...
2  | 20        | ...
3  | 30        | ...
```

**Что дальше?**

```sql
-- Вставка 2: Еще одна строка
INSERT INTO person_discounts (id, person_id, pizzeria_id, discount)
VALUES (???, 40, 5, 15);
       ↑
   Какой id использовать??? ROW_NUMBER() здесь НЕ РАБОТАЕТ!
```

❌ **Проблема:** ROW_NUMBER() работает только **ВНУТРИ** SELECT-запроса с несколькими строками.

Для одиночного INSERT нужно **ВРУЧНУЮ** указывать id:

```sql
INSERT INTO person_discounts (id, person_id, pizzeria_id, discount)
VALUES (4, 40, 5, 15);  -- вручную выбрали 4
```

---

### С SEQUENCE (ПОСТОЯННО)

```sql
-- Настройка один раз
CREATE SEQUENCE seq_person_discounts START 1;
ALTER TABLE person_discounts 
    ALTER COLUMN id SET DEFAULT NEXTVAL('seq_person_discounts');
SETVAL('seq_person_discounts', 3);  -- установили на 3

-- Вставка 1
INSERT INTO person_discounts (person_id, pizzeria_id, discount)
VALUES (10, 1, 10);
-- id=4 автоматически (NEXTVAL)

-- Вставка 2
INSERT INTO person_discounts (person_id, pizzeria_id, discount)
VALUES (20, 2, 15);
-- id=5 автоматически (NEXTVAL)

-- Вставка 3 (через неделю)
INSERT INTO person_discounts (person_id, pizzeria_id, discount)
VALUES (30, 3, 20);
-- id=6 автоматически (NEXTVAL)
```

✓ **SEQUENCE помнит последний номер** (3 → 4 → 5 → 6)

✓ Работает **всегда**, не только в SELECT

---

## ПРИМЕР 2: Удаление и повторная вставка

### С ROW_NUMBER()

```sql
-- Было в таблице:
id | name
---|------
1  | Вася
2  | Петя
3  | Коля

-- Удалили Петю
DELETE FROM persons WHERE id = 2;

-- Осталось:
id | name
---|------
1  | Вася
3  | Коля

-- Пересчитываем с ROW_NUMBER()
SELECT ROW_NUMBER() OVER (ORDER BY id) AS new_id, name
FROM persons;

new_id | name
-------|------
1      | Вася  ← было id=1, осталось 1
2      | Коля  ← было id=3, стало 2 (!)
```

**ROW_NUMBER() каждый раз ПЕРЕСЧИТЫВАЕТ** — номера изменяются!

---

### С SEQUENCE

```sql
-- Было в таблице:
id | name
---|------
1  | Вася
2  | Петя
3  | Коля

-- Удалили Петю
DELETE FROM persons WHERE id = 2;

-- Осталось:
id | name
---|------
1  | Вася
3  | Коля  ← id=3 остался 3 (не изменился!)

-- Вставляем нового
INSERT INTO persons (name) VALUES ('Маша');
-- id=4 (SEQUENCE не знает про удаление, продолжает с 4)

-- Результат:
id | name
---|------
1  | Вася
3  | Коля
4  | Маша  ← пропуск id=2 остался
```

**SEQUENCE НЕ ПЕРЕСЧИТЫВАЕТ** — пропуски остаются!

---

## СРАВНИТЕЛЬНАЯ ТАБЛИЦА

| Характеристика | ROW_NUMBER() | SEQUENCE |
|----------------|--------------|----------|
| **Что это?** | Оконная функция | Объект БД |
| **Когда работает** | Только в SELECT-запросе | Всегда (INSERT, UPDATE, SELECT) |
| **Сохраняется ли?** | ❌ Нет (пересчитывается каждый раз) | ✓ Да (хранит состояние) |
| **Помнит ли последний номер?** | ❌ Нет | ✓ Да |
| **Можно ли использовать в DEFAULT?** | ❌ Нет | ✓ Да |
| **Зависит от данных в таблице** | ✓ Да (нумерует то, что видит) | ❌ Нет (независим от таблицы) |
| **При удалении строк** | Пересчитывает номера | Пропускает номера |
| **Параллельные INSERT** | Может дублировать | Всегда уникальные |
| **Использование** | Временная нумерация в запросе | Постоянная генерация PRIMARY KEY |

---

## ПРИМЕР 3: Параллельные вставки

### С ROW_NUMBER() (ОПАСНО!)

**Сессия 1:**
```sql
-- В 10:00:00
INSERT INTO test (id, name)
SELECT ROW_NUMBER() OVER () AS id, name
FROM (VALUES ('Вася'), ('Петя')) AS t(name);
-- Генерирует id: 1, 2
```

**Сессия 2 (одновременно):**
```sql
-- В 10:00:00
INSERT INTO test (id, name)
SELECT ROW_NUMBER() OVER () AS id, name
FROM (VALUES ('Коля'), ('Маша')) AS t(name);
-- Генерирует id: 1, 2  ← ДУБЛИКАТЫ!
```

❌ **ОШИБКА:** "duplicate key value violates unique constraint"

**ROW_NUMBER() НЕ ЗНАЕТ** про параллельные вставки!

---

### С SEQUENCE (БЕЗОПАСНО)

**Сессия 1:**
```sql
-- В 10:00:00
INSERT INTO test (name) VALUES ('Вася');  -- id=1 (NEXTVAL)
INSERT INTO test (name) VALUES ('Петя');  -- id=2 (NEXTVAL)
```

**Сессия 2 (одновременно):**
```sql
-- В 10:00:00
INSERT INTO test (name) VALUES ('Коля');  -- id=3 (NEXTVAL)
INSERT INTO test (name) VALUES ('Маша');  -- id=4 (NEXTVAL)
```

✓ **ВСЕ УНИКАЛЬНЫ:** 1, 2, 3, 4

**SEQUENCE потокобезопасен** — разные сессии получают разные номера!

---

## КОГДА ИСПОЛЬЗОВАТЬ ЧТО?

### Используй ROW_NUMBER():

✓ **Временная нумерация** для отображения:
```sql
-- Нумерация в отчете
SELECT 
    ROW_NUMBER() OVER (ORDER BY salary DESC) AS rank,
    name,
    salary
FROM employees;
```

Результат:
```
rank | name  | salary
-----|-------|--------
1    | Иван  | 100000
2    | Петр  | 80000
3    | Мария | 75000
```

✓ **Пагинация** (постраничный вывод):
```sql
SELECT *
FROM (
    SELECT ROW_NUMBER() OVER (ORDER BY created_at) AS rn, *
    FROM articles
) t
WHERE rn BETWEEN 11 AND 20;  -- страница 2 (строки 11-20)
```

✓ **Одноразовая массовая вставка** (как в задании):
```sql
INSERT INTO person_discounts (id, ...)
SELECT ROW_NUMBER() OVER () AS id, ...
FROM grouped_data;
```

**ВАЖНО:** После этого нужно **SETVAL** для SEQUENCE!

---

### Используй SEQUENCE:

✓ **Постоянная генерация PRIMARY KEY:**
```sql
CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,  -- автоматически создает SEQUENCE
    customer_id BIGINT,
    total NUMERIC
);

INSERT INTO orders (customer_id, total) VALUES (1, 500);
-- id генерируется автоматически
```

✓ **Уникальные номера документов:**
```sql
CREATE SEQUENCE seq_invoice;

INSERT INTO invoices (invoice_number, amount)
VALUES ('INV-' || NEXTVAL('seq_invoice'), 1000);
-- INV-1, INV-2, INV-3...
```

✓ **Любая автоматическая нумерация** в production:
- Заказы
- Билеты
- Партии товаров
- Транзакции

---

## ПРИМЕР ИЗ ЗАДАНИЯ

### Почему использовали ОБА?

```sql
-- ШАГ 1: Массовая вставка с ROW_NUMBER()
DELETE FROM person_discounts;

INSERT INTO person_discounts (id, person_id, pizzeria_id, discount)
SELECT
    ROW_NUMBER() OVER () AS id,  -- временная нумерация: 1,2,3...
    person_id,
    pizzeria_id,
    discount
FROM person_order 
    INNER JOIN menu ON menu.id = person_order.menu_id
GROUP BY person_id, menu.pizzeria_id;

-- Результат: таблица с id 1,2,3,4,5

-- ШАГ 2: Настройка SEQUENCE для будущих INSERT
CREATE SEQUENCE seq_person_discounts START 1;

ALTER TABLE person_discounts 
    ALTER COLUMN id SET DEFAULT NEXTVAL('seq_person_discounts');

SETVAL('seq_person_discounts', (SELECT COUNT(*) + 1 FROM person_discounts));
-- Устанавливаем SEQUENCE на 6 (COUNT=5, +1=6)

-- ШАГ 3: Теперь можно вставлять без указания id
INSERT INTO person_discounts (person_id, pizzeria_id, discount)
VALUES (10, 5, 25);
-- id=6 автоматически (из SEQUENCE)
```

**Зачем два метода?**
1. **ROW_NUMBER()** — удобен для **одноразовой массовой** вставки
2. **SEQUENCE** — нужен для **будущих** одиночных INSERT

---

## ВИЗУАЛЬНОЕ СРАВНЕНИЕ

### ROW_NUMBER() — калькулятор

```
┌───────────────┐
│  Калькулятор  │
│               │
│  1 + 1 = 2    │  ← считаешь каждый раз заново
│  2 + 1 = 3    │
│  3 + 1 = 4    │
└───────────────┘

Выключил → забыл все
Включил → считаешь с 1 снова
```

### SEQUENCE — счетчик пробега в машине

```
┌───────────────┐
│   Счетчик     │
│   пробега     │
│               │
│  00042 км     │  ← помнит всегда
└───────────────┘

Выключил машину → счетчик ПОМНИТ (42 км)
Завтра поехал → счетчик продолжает (43, 44...)
```

---

## КОМБИНИРОВАНИЕ (как в задании)

```sql
-- Таблица пустая
-- ROW_NUMBER() для первой массовой вставки
INSERT INTO test (id, name)
SELECT ROW_NUMBER() OVER () AS id, name
FROM temp_data;
-- Вставили: id 1,2,3,4,5

-- Настроили SEQUENCE для продолжения
CREATE SEQUENCE seq_test START 1;
ALTER TABLE test ALTER COLUMN id SET DEFAULT NEXTVAL('seq_test');
SETVAL('seq_test', (SELECT MAX(id) FROM test));  -- установили на 5

-- Теперь SEQUENCE продолжает нумерацию
INSERT INTO test (name) VALUES ('Коля');  -- id=6 (SEQUENCE)
INSERT INTO test (name) VALUES ('Маша');  -- id=7 (SEQUENCE)
```

**ROW_NUMBER()** — для начальной загрузки
**SEQUENCE** — для дальнейшей работы

---

## КОРОТКИЙ ОТВЕТ

### ROW_NUMBER() OVER () AS id:
- ❌ **Временная нумерация** (только в момент запроса)
- ❌ Каждый раз **ПЕРЕСЧИТЫВАЕТСЯ**
- ❌ НЕ сохраняется в БД
- ❌ НЕ работает в DEFAULT
- ✓ Удобно для **отчетов**, **пагинации**, **одноразовой массовой вставки**

### SEQUENCE:
- ✓ **Постоянный генератор** (объект БД)
- ✓ **Помнит** последний номер
- ✓ Работает **всегда** (INSERT, UPDATE, SELECT)
- ✓ Работает в DEFAULT
- ✓ **Потокобезопасен** (параллельные INSERT)
- ✓ Для **постоянной генерации PRIMARY KEY**

### Аналогия:
**ROW_NUMBER()** = нумерация страниц при печати (одноразово)
**SEQUENCE** = нумератор билетов в очереди (постоянно помнит)

### В задании используются ОБА:
1. **ROW_NUMBER()** — для **первой** массовой вставки (1,2,3,4,5)
2. **SEQUENCE** — для **будущих** одиночных INSERT (6,7,8...)

Понятно теперь?



































































## ЧТО ТАКОЕ DEFAULT?

**DEFAULT** (значение по умолчанию) — это **автоматическое значение**, которое вставляется в столбец, если ты **НЕ указал** значение при INSERT.

### Аналогия: Форма заявления

Представь **бумажную анкету**:

```
┌─────────────────────────────────┐
│  АНКЕТА ДЛЯ РЕГИСТРАЦИИ        │
├─────────────────────────────────┤
│ Имя: ___________________       │
│                                 │
│ Страна: [Россия]    ← уже заполнено!
│                                 │
│ Статус: [Активен]   ← уже заполнено!
│                                 │
│ Дата регистрации: [Сегодня] ← уже заполнено!
└─────────────────────────────────┘
```

**Имя** — пустое (нужно заполнить вручную)
**Страна** — уже написано "Россия" (можешь оставить или изменить)
**Статус** — уже написано "Активен" (можешь оставить или изменить)
**Дата** — уже написано "Сегодня" (автоматически)

**DEFAULT — это заранее заполненные поля в форме!**

---

## КАК РАБОТАЕТ DEFAULT В SQL

### БЕЗ DEFAULT

```sql
CREATE TABLE users (
    id BIGINT PRIMARY KEY,
    name TEXT,
    country TEXT,
    status TEXT
);

-- Вставка данных
INSERT INTO users (id, name, country, status) 
VALUES (1, 'Вася', 'Россия', 'Активен');
```

Нужно **ВСЕГДА указывать все значения** вручную.

---

### С DEFAULT

```sql
CREATE TABLE users (
    id BIGINT PRIMARY KEY,
    name TEXT,
    country TEXT DEFAULT 'Россия',        -- ← DEFAULT
    status TEXT DEFAULT 'Активен'         -- ← DEFAULT
);

-- Вставка 1: Указываем все
INSERT INTO users (id, name, country, status) 
VALUES (1, 'Вася', 'Германия', 'Заблокирован');
-- country = 'Германия' (наше значение)
-- status = 'Заблокирован' (наше значение)

-- Вставка 2: НЕ указываем country и status
INSERT INTO users (id, name) 
VALUES (2, 'Петя');
-- country = 'Россия' (автоматически из DEFAULT!)
-- status = 'Активен' (автоматически из DEFAULT!)

-- Вставка 3: Указываем только country
INSERT INTO users (id, name, country) 
VALUES (3, 'Коля', 'Казахстан');
-- country = 'Казахстан' (наше значение)
-- status = 'Активен' (автоматически из DEFAULT!)
```

**Результат:**

```
id | name  | country    | status
---|-------|------------|-------------
1  | Вася  | Германия   | Заблокирован
2  | Петя  | Россия     | Активен      ← DEFAULT сработал!
3  | Коля  | Казахстан  | Активен      ← DEFAULT сработал!
```

---

## СИНТАКСИС: УСТАНОВКА DEFAULT

### При создании таблицы

```sql
CREATE TABLE table_name (
    column_name TYPE DEFAULT значение
);
```

**Примеры:**

```sql
CREATE TABLE products (
    id BIGSERIAL PRIMARY KEY,
    name TEXT,
    price NUMERIC DEFAULT 0,              -- число
    in_stock BOOLEAN DEFAULT true,        -- логическое
    created_at TIMESTAMP DEFAULT NOW(),   -- функция
    status TEXT DEFAULT 'available'       -- строка
);
```

---

### Для существующей таблицы

```sql
ALTER TABLE table_name 
    ALTER COLUMN column_name SET DEFAULT значение;
```

**Пример:**

```sql
-- Было: discount без DEFAULT
ALTER TABLE person_discounts 
    ALTER COLUMN discount SET DEFAULT 0;
-- Теперь: discount по умолчанию = 0
```

---

## ТИПЫ DEFAULT ЗНАЧЕНИЙ

### 1. Константы (фиксированные значения)

```sql
CREATE TABLE example (
    -- Числа
    age INTEGER DEFAULT 18,
    price NUMERIC DEFAULT 99.99,
    
    -- Строки
    country TEXT DEFAULT 'Россия',
    status TEXT DEFAULT 'new',
    
    -- Логические
    is_active BOOLEAN DEFAULT true,
    is_deleted BOOLEAN DEFAULT false,
    
    -- NULL
    notes TEXT DEFAULT NULL
);
```

---

### 2. Функции (вычисляемые значения)

```sql
CREATE TABLE example (
    -- Текущая дата/время
    created_at TIMESTAMP DEFAULT NOW(),
    created_date DATE DEFAULT CURRENT_DATE,
    
    -- Случайное число
    random_id UUID DEFAULT gen_random_uuid(),
    
    -- Текущий пользователь
    created_by TEXT DEFAULT CURRENT_USER
);
```

**NOW()** — текущая дата и время
**CURRENT_DATE** — текущая дата
**gen_random_uuid()** — случайный UUID
**CURRENT_USER** — имя текущего пользователя PostgreSQL

---

### 3. Выражения

```sql
CREATE TABLE example (
    base_price NUMERIC,
    tax_rate NUMERIC DEFAULT 0.20,
    -- Нельзя так: total_price NUMERIC DEFAULT base_price * (1 + tax_rate)
    -- DEFAULT не может ссылаться на другие столбцы той же строки!
);
```

⚠️ **ОГРАНИЧЕНИЕ:** DEFAULT **НЕ МОЖЕТ** использовать значения **других столбцов** той же строки.

**Можно:**
```sql
discount NUMERIC DEFAULT 0                    -- ✓ константа
created_at TIMESTAMP DEFAULT NOW()            -- ✓ функция
id BIGINT DEFAULT NEXTVAL('seq_name')         -- ✓ функция
```

**Нельзя:**
```sql
total NUMERIC DEFAULT price * quantity        -- ❌ другие столбцы
full_name TEXT DEFAULT first_name || ' ' || last_name  -- ❌ другие столбцы
```

Для вычисляемых столбцов используй **GENERATED COLUMN** (PostgreSQL 12+).

---

## КАК ИСПОЛЬЗОВАТЬ DEFAULT ПРИ INSERT

### Способ 1: НЕ указывать столбец

```sql
-- Столбец discount имеет DEFAULT 0
INSERT INTO person_discounts (person_id, pizzeria_id) 
VALUES (1, 5);
-- discount = 0 (автоматически)
```

Если столбец **НЕ упомянут** в списке, используется DEFAULT.

---

### Способ 2: Явно указать DEFAULT

```sql
INSERT INTO person_discounts (person_id, pizzeria_id, discount) 
VALUES (1, 5, DEFAULT);
--              ↑
-- Ключевое слово DEFAULT
```

Явно говоришь: "используй DEFAULT значение".

---

### Способ 3: Через DEFAULT VALUES

```sql
-- Все столбцы получают DEFAULT значения
INSERT INTO example DEFAULT VALUES;
```

Вставляет строку, где **ВСЕ** столбцы заполнены DEFAULT значениями.

---

## РАЗНИЦА: DEFAULT vs NULL

### NULL — это "пусто", "не знаю"

```sql
CREATE TABLE users (
    id BIGINT,
    name TEXT
);

INSERT INTO users (id) VALUES (1);
-- name = NULL (не указали, DEFAULT нет → NULL)
```

**NULL** означает "значение отсутствует".

---

### DEFAULT — это "подставь значение автоматически"

```sql
CREATE TABLE users (
    id BIGINT,
    name TEXT DEFAULT 'Неизвестно'
);

INSERT INTO users (id) VALUES (1);
-- name = 'Неизвестно' (DEFAULT сработал)
```

**DEFAULT** означает "если не указал — вставь вот это".

---

### Можно комбинировать

```sql
CREATE TABLE users (
    id BIGINT,
    name TEXT DEFAULT 'Неизвестно',
    email TEXT  -- нет DEFAULT → будет NULL
);

INSERT INTO users (id) VALUES (1);

-- Результат:
id | name        | email
---|-------------|-------
1  | Неизвестно  | NULL
   ↑             ↑
   DEFAULT       NULL (нет DEFAULT)
```

---

## ПРИМЕР С РАЗНЫМИ DEFAULT

```sql
CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,                      -- DEFAULT NEXTVAL(...)
    customer_id BIGINT,
    total NUMERIC DEFAULT 0,                       -- DEFAULT 0
    status TEXT DEFAULT 'pending',                 -- DEFAULT 'pending'
    created_at TIMESTAMP DEFAULT NOW(),            -- DEFAULT NOW()
    is_paid BOOLEAN DEFAULT false,                 -- DEFAULT false
    notes TEXT                                     -- нет DEFAULT (NULL)
);

-- Вставка с минимальными данными
INSERT INTO orders (customer_id, total) 
VALUES (123, 500);

-- Результат:
id | customer_id | total | status   | created_at           | is_paid | notes
---|-------------|-------|----------|----------------------|---------|-------
1  | 123         | 500   | pending  | 2026-03-15 14:30:00  | false   | NULL
↑                          ↑          ↑                       ↑         ↑
AUTO                     DEFAULT    DEFAULT                DEFAULT   NULL
```

---

## УДАЛЕНИЕ DEFAULT

```sql
ALTER TABLE table_name 
    ALTER COLUMN column_name DROP DEFAULT;
```

**Пример:**

```sql
-- Было: discount DEFAULT 0
ALTER TABLE person_discounts 
    ALTER COLUMN discount DROP DEFAULT;
-- Теперь: discount без DEFAULT (будет NULL при INSERT без значения)
```

---

## ИЗМЕНЕНИЕ DEFAULT

```sql
-- Было: status DEFAULT 'active'
ALTER TABLE users 
    ALTER COLUMN status SET DEFAULT 'pending';
-- Теперь: status DEFAULT 'pending'
```

⚠️ **ВАЖНО:** Изменение DEFAULT **НЕ ВЛИЯЕТ** на существующие строки! Только на новые INSERT.

**Пример:**

```sql
-- Таблица с данными
id | status
---|--------
1  | active
2  | active

-- Меняем DEFAULT
ALTER TABLE users ALTER COLUMN status SET DEFAULT 'pending';

-- Существующие строки НЕ ИЗМЕНИЛИСЬ:
id | status
---|--------
1  | active  ← не изменился
2  | active  ← не изменился

-- Новая вставка
INSERT INTO users (id) VALUES (3);

-- Результат:
id | status
---|--------
1  | active
2  | active
3  | pending ← новый DEFAULT сработал
```

---

## ПРАКТИЧЕСКИЕ ПРИМЕРЫ

### Пример 1: Автоматическая дата создания

```sql
CREATE TABLE articles (
    id BIGSERIAL PRIMARY KEY,
    title TEXT,
    content TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO articles (title, content) 
VALUES ('Заголовок', 'Текст статьи');

-- created_at и updated_at заполнятся автоматически текущим временем
```

---

### Пример 2: Статус по умолчанию

```sql
CREATE TABLE tasks (
    id BIGSERIAL PRIMARY KEY,
    title TEXT,
    status TEXT DEFAULT 'todo'  -- новые задачи по умолчанию "todo"
);

INSERT INTO tasks (title) VALUES ('Купить молоко');
INSERT INTO tasks (title) VALUES ('Позвонить врачу');

-- Все задачи автоматически получают status='todo'
```

---

### Пример 3: Счетчик по умолчанию

```sql
CREATE TABLE products (
    id BIGSERIAL PRIMARY KEY,
    name TEXT,
    views INTEGER DEFAULT 0  -- счетчик просмотров начинается с 0
);

INSERT INTO products (name) VALUES ('Товар А');
-- views = 0 автоматически

UPDATE products SET views = views + 1 WHERE id = 1;
-- views = 1
```

---

### Пример 4: Логический флаг

```sql
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    email TEXT,
    is_verified BOOLEAN DEFAULT false,  -- новые пользователи не подтверждены
    is_active BOOLEAN DEFAULT true      -- но активны
);

INSERT INTO users (email) VALUES ('user@example.com');

-- Результат:
id | email             | is_verified | is_active
---|-------------------|-------------|----------
1  | user@example.com  | false       | true
```

---

### Пример 5: Автогенерация номера

```sql
CREATE SEQUENCE seq_invoice START 1000;

CREATE TABLE invoices (
    id BIGSERIAL PRIMARY KEY,
    invoice_number TEXT DEFAULT 'INV-' || NEXTVAL('seq_invoice'),
    amount NUMERIC
);

INSERT INTO invoices (amount) VALUES (500);
-- invoice_number = 'INV-1000'

INSERT INTO invoices (amount) VALUES (1500);
-- invoice_number = 'INV-1001'
```

---

## DEFAULT vs NOT NULL vs CHECK

```sql
CREATE TABLE example (
    -- Только DEFAULT
    status TEXT DEFAULT 'active',
    -- Можно вставить NULL явно
    
    -- DEFAULT + NOT NULL
    country TEXT DEFAULT 'Россия' NOT NULL,
    -- Нельзя вставить NULL (даже явно)
    
    -- DEFAULT + CHECK
    discount NUMERIC DEFAULT 0 CHECK (discount BETWEEN 0 AND 100),
    -- Должно быть от 0 до 100
    
    -- Все вместе
    age INTEGER DEFAULT 18 NOT NULL CHECK (age >= 18)
    -- По умолчанию 18, нельзя NULL, должно быть >= 18
);
```

---

## ПОСМОТРЕТЬ DEFAULT ЗНАЧЕНИЯ

### Через psql:

```sql
\d person_discounts
```

Результат:
```
     Column      |  Type   | Default
-----------------|---------|-------------------
 id              | bigint  | nextval('seq_...')
 person_id       | bigint  |
 pizzeria_id     | bigint  |
 discount        | numeric | 0
```

---

### Через SQL:

```sql
SELECT 
    column_name, 
    column_default
FROM information_schema.columns
WHERE table_name = 'person_discounts';
```

Результат:
```
column_name   | column_default
--------------|---------------------------
id            | nextval('seq_person_discounts'::regclass)
person_id     | NULL
pizzeria_id   | NULL
discount      | 0
```

---

## ОСОБЕННОСТИ DEFAULT

### 1. DEFAULT вычисляется при INSERT

```sql
CREATE TABLE example (
    id BIGSERIAL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Вставка 1 в 10:00
INSERT INTO example DEFAULT VALUES;
-- created_at = 2026-03-15 10:00:00

-- Вставка 2 в 10:05
INSERT INTO example DEFAULT VALUES;
-- created_at = 2026-03-15 10:05:00

-- NOW() вызывается КАЖДЫЙ РАЗ при INSERT!
```

---

### 2. DEFAULT НЕ работает при UPDATE

```sql
CREATE TABLE example (
    status TEXT DEFAULT 'active'
);

INSERT INTO example DEFAULT VALUES;
-- status = 'active'

UPDATE example SET status = NULL;
-- status = NULL (DEFAULT НЕ сработал!)

-- DEFAULT работает только при INSERT, не при UPDATE
```

---

### 3. DEFAULT NULL vs отсутствие DEFAULT

```sql
-- Вариант 1: Явный DEFAULT NULL
CREATE TABLE t1 (col TEXT DEFAULT NULL);

-- Вариант 2: Без DEFAULT
CREATE TABLE t2 (col TEXT);

-- Оба ведут себя ОДИНАКОВО при INSERT без значения
INSERT INTO t1 DEFAULT VALUES;  -- col = NULL
INSERT INTO t2 (id) VALUES (1); -- col = NULL (если есть другой столбец id)
```

Разница только в **метаданных** (явно указан DEFAULT или нет).

---

## КОРОТКИЙ ОТВЕТ

**DEFAULT** — это **значение по умолчанию** для столбца.

### Что делает:
- Автоматически подставляется при INSERT, если значение **НЕ указано**
- Можно указать **константу**, **функцию** или **NULL**

### Синтаксис:

**При создании таблицы:**
```sql
CREATE TABLE t (col TYPE DEFAULT значение);
```

**Для существующей таблицы:**
```sql
ALTER TABLE t ALTER COLUMN col SET DEFAULT значение;
```

**Удалить:**
```sql
ALTER TABLE t ALTER COLUMN col DROP DEFAULT;
```

### Примеры:

```sql
-- Число
price NUMERIC DEFAULT 0

-- Строка
status TEXT DEFAULT 'active'

-- Логическое
is_active BOOLEAN DEFAULT true

-- Функция
created_at TIMESTAMP DEFAULT NOW()

-- Последовательность
id BIGINT DEFAULT NEXTVAL('seq_name')
```

### Аналогия:
**DEFAULT = заранее заполненное поле в анкете**
- Можешь оставить (не указывать при INSERT)
- Можешь изменить (указать свое значение)

### В задании:
```sql
ALTER TABLE person_discounts ALTER COLUMN discount SET DEFAULT 0;
```

Теперь:
```sql
INSERT INTO person_discounts (person_id, pizzeria_id) VALUES (1, 5);
-- discount = 0 автоматически (из DEFAULT)
```

Понятно теперь?






















































## ОБЪЯСНЯЮ ЗАДАНИЕ ПРОСТЫМИ СЛОВАМИ

### Представь ситуацию:

У тебя есть **тетрадь** (таблица `person_discounts`), где ты записываешь скидки.

В тетради уже есть **5 записей** с номерами:

```
№ | Клиент | Скидка
--|--------|-------
1 | Вася   | 10%
2 | Петя   | 20%
3 | Коля   | 15%
4 | Маша   | 25%
5 | Дима   | 30%
```

Тебе надоело **ВРУЧНУЮ** придумывать номера для каждой новой записи.

### Задание говорит:

**"Купи автомат-нумератор (SEQUENCE), который будет АВТОМАТИЧЕСКИ давать номера новым записям"**

---

## РАЗБОР СТРОКИ ПО СТРОКЕ

### Строка 1: Покупаем нумератор

```sql
CREATE SEQUENCE seq_person_discounts START 1;
```

**ЧТО ПРОИСХОДИТ:**

Ты покупаешь **автомат-нумератор** (как в очереди в поликлинике).

```
┌──────────────────┐
│  НУМЕРАТОР       │
│                  │
│  Текущий номер:  │
│       001        │
│                  │
│  [ВЗЯТЬ БИЛЕТ]   │
└──────────────────┘
```

Автомат начинает с номера **1**.

---

### Строка 2: Привязываем нумератор к тетради

```sql
ALTER TABLE person_discounts 
    ALTER COLUMN id SET DEFAULT NEXTVAL('seq_person_discounts');
```

**ЧТО ПРОИСХОДИТ:**

Ты говоришь: **"Каждый раз, когда я добавляю новую запись в тетрадь БЕЗ номера, автоматически нажми кнопку на нумераторе и вставь этот номер!"**

### Разберем по частям:

**ALTER TABLE person_discounts** = "Меняю правила для тетради person_discounts"

**ALTER COLUMN id** = "Конкретно для колонки 'номер' (id)"

**SET DEFAULT** = "Устанавливаю значение ПО УМОЛЧАНИЮ" (что вставлять автоматически, если не указано)

**NEXTVAL('seq_person_discounts')** = "Нажми кнопку на нумераторе и возьми следующий номер"

### АНАЛОГИЯ:

```
БЫЛО (без DEFAULT):
┌────────────────────────────────┐
│ Новая запись:                  │
│ № [____] ← нужно написать ВРУЧНУЮ
│ Клиент: [Света]                │
│ Скидка: [20%]                  │
└────────────────────────────────┘

СТАЛО (с DEFAULT NEXTVAL):
┌────────────────────────────────┐
│ Новая запись:                  │
│ № [AUTO] ← АВТОМАТИЧЕСКИ из нумератора!
│ Клиент: [Света]                │
│ Скидка: [20%]                  │
└────────────────────────────────┘
```

---

## ЗАЧЕМ НУЖЕН NEXTVAL?

**NEXTVAL** = "дай мне СЛЕДУЮЩИЙ номер из нумератора"

### БЕЗ NEXTVAL (вручную):

```sql
INSERT INTO person_discounts (id, person_id, pizzeria_id, discount)
VALUES (6, 10, 5, 15);
     ↑
   Придумал сам: 6

INSERT INTO person_discounts (id, person_id, pizzeria_id, discount)
VALUES (7, 11, 3, 20);
     ↑
   Опять вручную: 7
```

Каждый раз думаешь: "Какой следующий номер? 6? 7? 8?"

**Можно ошибиться!** Забыл, что 6 уже есть → вставил 6 снова → **ОШИБКА!**

---

### С NEXTVAL (автоматически):

```sql
INSERT INTO person_discounts (person_id, pizzeria_id, discount)
VALUES (10, 5, 15);
-- id = 6 АВТОМАТИЧЕСКИ (нумератор выдал)

INSERT INTO person_discounts (person_id, pizzeria_id, discount)
VALUES (11, 3, 20);
-- id = 7 АВТОМАТИЧЕСКИ (нумератор выдал)
```

**НЕ НУЖНО** думать про номера! Нумератор сам выдает: 6, 7, 8, 9...

---

## ЗАЧЕМ SETVAL?

### Проблема:

Нумератор **новый** — он начинает с **1**.

Но в тетради **УЖЕ ЕСТЬ** записи с номерами 1, 2, 3, 4, 5!

```sql
CREATE SEQUENCE seq_person_discounts START 1;
-- Нумератор: текущий номер = 1
```

Что будет, если вставить новую запись?

```sql
INSERT INTO person_discounts (person_id, pizzeria_id, discount)
VALUES (10, 5, 15);
-- Нумератор выдаст номер 1
-- Попытка вставить id=1

❌ ОШИБКА! id=1 уже существует в тетради!
```

### Решение: SETVAL

```sql
SELECT SETVAL(
    'seq_person_discounts', 
    (SELECT COUNT(*) + 1 FROM person_discounts)
);
```

**ЧТО ПРОИСХОДИТ:**

Ты **перематываешь нумератор** на правильный номер:

1. Считаешь записи в тетради: COUNT(*) = 5
2. Прибавляешь 1: 5 + 1 = 6
3. Устанавливаешь нумератор на 6

```
БЫЛО:
┌──────────────────┐
│  НУМЕРАТОР       │
│  Текущий номер:  │
│       001        │  ← Начинает с 1 (конфликт!)
└──────────────────┘

ПОСЛЕ SETVAL:
┌──────────────────┐
│  НУМЕРАТОР       │
│  Текущий номер:  │
│       006        │  ← Установили на 6 (следующий свободный)
└──────────────────┘
```

Теперь следующая запись получит номер **6** → нет конфликта!

---

## ПОРЯДОК ВЫПОЛНЕНИЯ СКРИПТА

### ШАГ 1: Удаляем старый нумератор (если есть)

```sql
DROP SEQUENCE IF EXISTS seq_person_discounts CASCADE;
```

**ЧТО ПРОИСХОДИТ:**
- Выбрасываем старый нумератор (если был)
- CASCADE — отключаем его от всех тетрадей, где он использовался

**АНАЛОГИЯ:** Убираешь старый сломанный нумератор из очереди.

---

### ШАГ 2: Покупаем новый нумератор

```sql
CREATE SEQUENCE seq_person_discounts START 1;
```

**ЧТО ПРОИСХОДИТ:**
- Создаем новый нумератор
- Он начинает с номера **1**

**СОСТОЯНИЕ НУМЕРАТОРА:**
```
Текущий номер: 1
Следующий выдаст: 1
```

**АНАЛОГИЯ:** Купил новый нумератор билетов, он на заводе настроен на 001.

---

### ШАГ 3: Привязываем нумератор к столбцу id

```sql
ALTER TABLE person_discounts 
    ALTER COLUMN id SET DEFAULT NEXTVAL('seq_person_discounts');
```

**ЧТО ПРОИСХОДИТ:**
- Говорим столбцу `id`: "Если при INSERT тебя не указали, возьми номер из нумератора"
- Теперь `id` **СВЯЗАН** с нумератором

**АНАЛОГИЯ:** Повесил табличку: "При выдаче нового бланка автоматически проставлять номер из автомата А-123"

**СОСТОЯНИЕ:**
```
Таблица person_discounts:
- Столбец id теперь имеет DEFAULT = "взять из seq_person_discounts"
```

---

### ШАГ 4: Перематываем нумератор на правильный номер

```sql
SELECT SETVAL(
    'seq_person_discounts', 
    (SELECT COUNT(*) + 1 FROM person_discounts)
);
```

**ЧТО ПРОИСХОДИТ:**

**Шаг 4.1:** Подзапрос считает строки
```sql
SELECT COUNT(*) + 1 FROM person_discounts
-- Допустим, в таблице 5 записей
-- COUNT(*) = 5
-- 5 + 1 = 6
-- Возвращает: 6
```

**Шаг 4.2:** SETVAL устанавливает нумератор на 6
```sql
SETVAL('seq_person_discounts', 6)
```

**СОСТОЯНИЕ НУМЕРАТОРА ПОСЛЕ:**
```
Текущий номер: 6
Следующий выдаст: 7
```

**АНАЛОГИЯ:** Перемотал нумератор с 001 на 006, потому что билеты 1-5 уже выданы вручную.

---

### ШАГ 5: Проверка

```sql
SELECT 
    COUNT(*) = 1 AS check1,
    MAX("start_value") = 1 AS check2,
    MAX("last_value") > 5 AS check3
FROM pg_sequences
WHERE sequencename = 'seq_person_discounts';
```

**ЧТО ПРОИСХОДИТ:**
- Проверяем, что нумератор создан и настроен правильно

**Проверка 1:** `COUNT(*) = 1` — нумератор существует (найден ровно 1)

**Проверка 2:** `MAX("start_value") = 1` — начальное значение было 1 (из CREATE SEQUENCE START 1)

**Проверка 3:** `MAX("last_value") > 5` — текущее значение больше 5 (значит SETVAL отработал, учел 5 существующих записей)

---

## ОБЩАЯ СХЕМА

```
┌─────────────────────────────────────────┐
│ ШАГ 1: Удаляем старый нумератор         │
│ DROP SEQUENCE IF EXISTS ...             │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│ ШАГ 2: Создаем новый нумератор          │
│ CREATE SEQUENCE ... START 1             │
│ Состояние: текущий номер = 1            │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│ ШАГ 3: Привязываем к столбцу id         │
│ ALTER TABLE ... SET DEFAULT NEXTVAL()   │
│ Теперь: INSERT без id → автономер       │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│ ШАГ 4: Перематываем на правильный номер │
│ SETVAL(..., COUNT(*) + 1)               │
│ Было: 1 → Стало: 6                      │
│ (учитываем 5 существующих записей)      │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│ ШАГ 5: Проверяем                        │
│ SELECT ... FROM pg_sequences            │
│ ✓ Нумератор создан                      │
│ ✓ Начинается с 1                        │
│ ✓ Текущее значение > 5                  │
└─────────────────────────────────────────┘
```

---

## ЧТО ПРОИСХОДИТ ПОСЛЕ ВЫПОЛНЕНИЯ СКРИПТА

### ТЕПЕРЬ можно вставлять БЕЗ указания id:

```sql
INSERT INTO person_discounts (person_id, pizzeria_id, discount)
VALUES (10, 5, 15);
```

**ЧТО ПРОИСХОДИТ ВНУТРИ:**

1. PostgreSQL видит: "id не указан"
2. Смотрит DEFAULT для id: `NEXTVAL('seq_person_discounts')`
3. Вызывает функцию NEXTVAL
4. NEXTVAL обращается к нумератору: "Дай следующий номер"
5. Нумератор: "Текущий 6, выдаю 7, запоминаю новый текущий 7"
6. NEXTVAL возвращает 7
7. PostgreSQL вставляет: id=7

**РЕЗУЛЬТАТ:**

```
№ | Клиент | Скидка
--|--------|-------
1 | Вася   | 10%
2 | Петя   | 20%
3 | Коля   | 15%
4 | Маша   | 25%
5 | Дима   | 30%
7 | id=10  | 15%  ← АВТОМАТИЧЕСКИ получил id=7
```

---

## ФИНАЛЬНОЕ ОБЪЯСНЕНИЕ ALTER TABLE ... SET DEFAULT NEXTVAL

```sql
ALTER TABLE person_discounts 
    ALTER COLUMN id SET DEFAULT NEXTVAL('seq_person_discounts');
```

### ПРОСТЫМИ СЛОВАМИ:

**"Для таблицы person_discounts, для столбца id, установи правило: если при вставке новой строки id НЕ указан, автоматически возьми следующий номер из нумератора seq_person_discounts"**

### ЕЩЕ ПРОЩЕ:

**"id теперь заполняется АВТОМАТИЧЕСКИ из нумератора"**

### АНАЛОГИЯ:

Представь **форму заявления**:

**БЫЛО:**
```
Заявление №: [____]  ← нужно вписать вручную
```

**СТАЛО:**
```
Заявление №: [АВТО]  ← автоматически из нумератора
```

Ты больше НЕ ЗАПОЛНЯЕШЬ номер вручную — он проставляется автоматически.

---

## КОРОТКИЙ ОТВЕТ

### Задание:
Создать автоматический нумератор (SEQUENCE) для столбца id, чтобы при вставке новых записей **НЕ НУЖНО** было вручную придумывать номера.

### Что делает строка:
```sql
ALTER TABLE person_discounts 
    ALTER COLUMN id SET DEFAULT NEXTVAL('seq_person_discounts');
```

**Связывает столбец id с автоматом-нумератором:**
- При INSERT **БЕЗ** указания id → PostgreSQL **автоматически** берет следующий номер из нумератора
- Ты больше НЕ ПИШЕШЬ id вручную

### Зачем NEXTVAL:
**NEXTVAL** = "дай следующий номер"

Это **ФУНКЦИЯ**, которая:
1. Обращается к нумератору
2. Спрашивает: "Какой следующий?"
3. Нумератор выдает номер и увеличивает счетчик
4. Возвращает этот номер

### Порядок выполнения:
1. Удаляем старый нумератор
2. Создаем новый (начинается с 1)
3. **Связываем** нумератор со столбцом id (SET DEFAULT NEXTVAL)
4. Перематываем нумератор на правильный номер (чтобы не было конфликтов)
5. Проверяем, что все работает

### Результат:
```sql
-- БЫЛО (вручную):
INSERT INTO person_discounts (id, person_id, ...) VALUES (6, 10, ...);
                              ↑ придумал сам

-- СТАЛО (автоматически):
INSERT INTO person_discounts (person_id, ...) VALUES (10, ...);
-- id=6 автоматически из нумератора
```

Понятно теперь?






