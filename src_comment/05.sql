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














-- Добавляем комментарий к столбцу id таблицы person_discounts
-- COMMENT ON COLUMN - команда для добавления описания (документации) к столбцу
-- person_discounts.id - указываем таблицу и столбец (формат: таблица.столбец)
-- IS - ключевое слово, после которого идет текст комментария
-- 'primary key identifier' - текст комментария (описание столбца на английском)
-- Это документация для других разработчиков: "id - это первичный ключ"
COMMENT ON COLUMN person_discounts.id 
    IS 'primary key identifier';

-- Добавляем комментарий к столбцу person_id
-- 'person identifier' - описывает, что это идентификатор человека (клиента)
-- Помогает понять: "person_id ссылается на таблицу person"
COMMENT ON COLUMN person_discounts.person_id 
    IS 'person identifier';

-- Добавляем комментарий к столбцу pizzeria_id
-- 'pizzeria identifier' - описывает, что это идентификатор пиццерии
-- Помогает понять: "pizzeria_id ссылается на таблицу pizzeria"
COMMENT ON COLUMN person_discounts.pizzeria_id 
    IS 'pizzeria identifier';

-- Добавляем комментарий к столбцу discount
-- 'discount for pair person and pizzeria' - более подробное описание
-- Объясняет бизнес-логику: "скидка для конкретной пары человек+пиццерия"
-- Это важно: скидка индивидуальная для каждой комбинации
COMMENT ON COLUMN person_discounts.discount 
    IS 'discount for pair person and pizzeria';

-- Добавляем комментарий к самой таблице
-- COMMENT ON TABLE - команда для добавления описания к таблице (не к столбцу)
-- person_discounts - имя таблицы
-- 'Discounts for persons' - краткое описание назначения таблицы
-- Объясняет: "эта таблица хранит персональные скидки для клиентов"
COMMENT ON TABLE person_discounts 
    IS 'Discounts for persons';


-- Проверка успешности добавления комментариев
-- SELECT COUNT(*) = 5 - проверяем, что добавлено ровно 5 комментариев
-- AS check - называем результат "check"
SELECT COUNT(*) = 5 AS check
-- FROM pg_description - системная таблица PostgreSQL, хранящая все комментарии
-- pg_description содержит описания (комментарии) для всех объектов БД
FROM pg_description
-- WHERE objoid = 'person_discounts'::regclass
-- objoid - ID объекта (таблицы, столбца и т.д.) в PostgreSQL
-- 'person_discounts'::regclass - преобразуем имя таблицы в её внутренний ID
-- ::regclass - специальный тип данных PostgreSQL для ссылок на таблицы
-- Это находит ВСЕ комментарии, связанные с таблицей person_discounts:
--   1 комментарий для таблицы + 4 комментария для столбцов = 5 всего
WHERE objoid = 'person_discounts'::regclass;
-- Ожидаемый результат: true (найдено 5 комментариев)
```

---

## КРАТКИЙ ПЕРЕСКАЗ ДЛЯ УСТНОЙ ЗАЩИТЫ:

**Строки 1-4**: Добавляю комментарий к столбцу id — объясняю, что это первичный ключ (уникальный идентификатор записи).

**Строки 6-9**: Добавляю комментарий к person_id — это идентификатор клиента, ссылается на таблицу person.

**Строки 11-14**: Добавляю комментарий к pizzeria_id — это идентификатор пиццерии, ссылается на таблицу pizzeria.

**Строки 16-20**: Добавляю комментарий к discount — объясняю бизнес-логику: скидка персональная для каждой пары "человек + пиццерия".

**Строки 22-26**: Добавляю комментарий к самой таблице person_discounts — кратко описываю её назначение: хранит скидки для клиентов.

**Строки 28-41**: Проверочный запрос к системной таблице pg_description — подтверждаю, что добавлено ровно 5 комментариев (1 для таблицы + 4 для столбцов). ::regclass преобразует имя таблицы в её внутренний ID для поиска.

---

## ЧТО ТАКОЕ COMMENT?

**COMMENT** — это команда для добавления **документации** (описания) к объектам базы данных.

### Аналогия: Ценники в магазине

Представь **магазин**:

**БЕЗ комментариев (ценников):**
```
Полка 1: [загадочная коробка]
Полка 2: [странная банка]
Полка 3: [непонятный пакет]
```

Покупатель в растерянности: "Что это? Для чего? Сколько стоит?"

**С комментариями (ценниками):**
```
Полка 1: [коробка] ← "Хлопья 'Nestle', 500г, 250₽"
Полка 2: [банка]   ← "Консервы тунца, 200г, 180₽"
Полка 3: [пакет]   ← "Рис басмати, 1кг, 320₽"
```

Теперь понятно!

### В базе данных:

**БЕЗ комментариев:**
```sql
\d person_discounts

     Column      |  Type   |
-----------------|---------|
 id              | bigint  |
 person_id       | bigint  |
 pizzeria_id     | bigint  |
 discount        | numeric |
```

Разработчик думает: "person_id — это что? На что ссылается? Что хранит discount?"

**С комментариями:**
```sql
\d+ person_discounts

     Column      |  Type   | Description
-----------------|---------|----------------------------------
 id              | bigint  | primary key identifier
 person_id       | bigint  | person identifier
 pizzeria_id     | bigint  | pizzeria identifier
 discount        | numeric | discount for pair person and pizzeria
```

Теперь все понятно!

---

## ЗАЧЕМ НУЖНЫ КОММЕНТАРИИ?

### 1. Документация для других разработчиков

Через полгода новый человек в команде смотрит на таблицу:
```sql
SELECT * FROM person_discounts;
```

Комментарии помогают понять:
- Что хранит таблица? → "Discounts for persons"
- Что такое discount? → "discount for pair person and pizzeria"

### 2. Бизнес-логика

Комментарий объясняет **ПОЧЕМУ** таблица так устроена:
```
'discount for pair person and pizzeria'
```

Разработчик понимает: "Ага! Скидка **индивидуальная** для каждой пары. Один человек может иметь разные скидки в разных пиццериях!"

### 3. Data Governance (управление данными)

В больших компаниях есть **правила документирования**:
- Каждая таблица ДОЛЖНА иметь описание
- Каждый столбец ДОЛЖЕН быть прокомментирован

Это часть **Data Governance Policies** (политика управления данными) — стандарты качества данных.

---

## СИНТАКСИС COMMENT

```sql
COMMENT ON { TABLE | COLUMN | CONSTRAINT | INDEX | ... } название IS 'текст'
            ↓        ↓          ↓            ↓
      тип объекта  имя объекта              описание
```

### Примеры:

**Таблица:**
```sql
COMMENT ON TABLE person_discounts IS 'Discounts for persons';
```

**Столбец:**
```sql
COMMENT ON COLUMN person_discounts.discount IS 'discount percentage';
```

**Constraint:**
```sql
COMMENT ON CONSTRAINT fk_person_discounts_person_id 
    ON person_discounts 
    IS 'foreign key to person table';
```

**Индекс:**
```sql
COMMENT ON INDEX idx_person_discounts_unique 
    IS 'ensures unique pair person-pizzeria';
```

**База данных:**
```sql
COMMENT ON DATABASE mydb IS 'Production database for pizza orders';
```

---

## ЧТО ТАКОЕ pg_description?

**pg_description** — системная таблица PostgreSQL, которая хранит **ВСЕ комментарии**.

### Структура (упрощенно):

```
objoid    | classoid | objsubid | description
----------|----------|----------|---------------------------
12345     | 1259     | 0        | 'Discounts for persons'
12345     | 1259     | 1        | 'primary key identifier'
12345     | 1259     | 2        | 'person identifier'
12345     | 1259     | 3        | 'pizzeria identifier'
12345     | 1259     | 4        | 'discount for pair...'
```

**objoid** — ID объекта (таблицы)
**classoid** — тип объекта (1259 = таблица)
**objsubid** — номер подобъекта (0 = сама таблица, 1-4 = столбцы)
**description** — текст комментария

---

## ЧТО ТАКОЕ ::regclass?

**::regclass** — специальный тип данных PostgreSQL для **ссылок на таблицы**.

### Проблема: Как найти таблицу?

У каждой таблицы есть **внутренний ID** (число), например: `12345`.

Но мы хотим искать по **имени**: `person_discounts`.

### ::regclass преобразует имя в ID:

```sql
'person_discounts'::regclass
       ↓
   12345  (внутренний ID таблицы)
```

### В запросе:

```sql
SELECT COUNT(*) = 5
FROM pg_description
WHERE objoid = 'person_discounts'::regclass;
             ↓
WHERE objoid = 12345;
```

PostgreSQL **автоматически** находит ID таблицы по её имени.

---

### Альтернатива БЕЗ ::regclass:

```sql
SELECT COUNT(*) = 5
FROM pg_description
WHERE objoid = (
    SELECT oid FROM pg_class WHERE relname = 'person_discounts'
);
```

**::regclass** — это **короткая запись** для такого подзапроса.

---

## ПОЧЕМУ COUNT(*) = 5?

Мы добавили **5 комментариев**:

1. **Таблица:** person_discounts
2. **Столбец:** id
3. **Столбец:** person_id
4. **Столбец:** pizzeria_id
5. **Столбец:** discount

В `pg_description` для таблицы `person_discounts` должно быть ровно **5 записей**.

---

## АЛЬТЕРНАТИВНЫЕ СПОСОБЫ РЕШЕНИЯ

### Способ 1: Русские комментарии

```sql
COMMENT ON COLUMN person_discounts.id 
    IS 'Первичный ключ (уникальный идентификатор записи)';

COMMENT ON COLUMN person_discounts.person_id 
    IS 'Идентификатор клиента (ссылка на таблицу person)';

COMMENT ON COLUMN person_discounts.pizzeria_id 
    IS 'Идентификатор пиццерии (ссылка на таблицу pizzeria)';

COMMENT ON COLUMN person_discounts.discount 
    IS 'Процент скидки для конкретной пары клиент-пиццерия';

COMMENT ON TABLE person_discounts 
    IS 'Таблица персональных скидок клиентов в пиццериях';

SELECT COUNT(*) = 5 AS check
FROM pg_description
WHERE objoid = 'person_discounts'::regclass;
```

**Плюсы:**
- Понятнее для русскоязычной команды

**Минусы:**
- Может быть проблема с кодировкой
- Международные команды не поймут

---

### Способ 2: Более детальные комментарии

```sql
COMMENT ON COLUMN person_discounts.id 
    IS 'Unique identifier (Primary Key). Auto-generated via SEQUENCE.';

COMMENT ON COLUMN person_discounts.person_id 
    IS 'Foreign key to person.id. References the customer receiving the discount.';

COMMENT ON COLUMN person_discounts.pizzeria_id 
    IS 'Foreign key to pizzeria.id. References the pizzeria offering the discount.';

COMMENT ON COLUMN person_discounts.discount 
    IS 'Discount percentage (0-100). Personal discount for the pair (person, pizzeria). Example: 10.5 means 10.5% off.';

COMMENT ON TABLE person_discounts 
    IS 'Personal discounts for customers in specific pizzerias. One person can have different discounts in different pizzerias.';

SELECT COUNT(*) = 5 AS check
FROM pg_description
WHERE objoid = 'person_discounts'::regclass;
```

**Плюсы:**
- Максимально подробно
- Объясняет бизнес-логику

**Минусы:**
- Слишком длинно

---

### Способ 3: С указанием схемы (public)

```sql
COMMENT ON COLUMN public.person_discounts.id 
    IS 'primary key identifier';

COMMENT ON COLUMN public.person_discounts.person_id 
    IS 'person identifier';

COMMENT ON COLUMN public.person_discounts.pizzeria_id 
    IS 'pizzeria identifier';

COMMENT ON COLUMN public.person_discounts.discount 
    IS 'discount for pair person and pizzeria';

COMMENT ON TABLE public.person_discounts 
    IS 'Discounts for persons';

SELECT COUNT(*) = 5 AS check
FROM pg_description
WHERE objoid = 'public.person_discounts'::regclass;
```

**public** — имя схемы по умолчанию

**Плюсы:**
- Явно указана схема
- Полезно при работе с несколькими схемами

**Минусы:**
- Избыточно для простых проектов

---

### Способ 4: Через DO блок (автоматизация)

```sql
DO $$
DECLARE
    comments TEXT[][] := ARRAY[
        ['COLUMN', 'id', 'primary key identifier'],
        ['COLUMN', 'person_id', 'person identifier'],
        ['COLUMN', 'pizzeria_id', 'pizzeria identifier'],
        ['COLUMN', 'discount', 'discount for pair person and pizzeria'],
        ['TABLE', '', 'Discounts for persons']
    ];
    comment_row TEXT[];
BEGIN
    FOREACH comment_row SLICE 1 IN ARRAY comments
    LOOP
        IF comment_row[1] = 'TABLE' THEN
            EXECUTE format('COMMENT ON TABLE person_discounts IS %L', comment_row[3]);
        ELSE
            EXECUTE format('COMMENT ON COLUMN person_discounts.%I IS %L', comment_row[2], comment_row[3]);
        END IF;
    END LOOP;
END $$;

SELECT COUNT(*) = 5 AS check
FROM pg_description
WHERE objoid = 'person_discounts'::regclass;
```

**DO блок** — анонимная функция для выполнения сложной логики

**Минусы:**
- Слишком сложно
- ❌ НЕ РЕКОМЕНДУЕТСЯ для простой задачи

---

### Способ 5: С удалением старых комментариев

```sql
-- Удаляем старые комментарии (если есть)
COMMENT ON COLUMN person_discounts.id IS NULL;
COMMENT ON COLUMN person_discounts.person_id IS NULL;
COMMENT ON COLUMN person_discounts.pizzeria_id IS NULL;
COMMENT ON COLUMN person_discounts.discount IS NULL;
COMMENT ON TABLE person_discounts IS NULL;

-- Добавляем новые
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
```

**IS NULL** — удаляет комментарий

**Плюсы:**
- Идемпотентность (можно запускать многократно)

**Минусы:**
- Избыточно (COMMENT ON автоматически перезаписывает)

---

### Способ 6: Проверка через information_schema

```sql
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

-- Альтернативная проверка через information_schema
SELECT COUNT(*) >= 4 AS check
FROM information_schema.columns
WHERE table_name = 'person_discounts'
  AND column_comment IS NOT NULL;
```

**Минусы:**
- `information_schema.columns` не всегда содержит поле `column_comment` (зависит от версии PostgreSQL)
- ❌ Может не работать

---

### Способ 7: С проверкой существования таблицы

```sql
DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_tables WHERE tablename = 'person_discounts') THEN
        COMMENT ON COLUMN person_discounts.id IS 'primary key identifier';
        COMMENT ON COLUMN person_discounts.person_id IS 'person identifier';
        COMMENT ON COLUMN person_discounts.pizzeria_id IS 'pizzeria identifier';
        COMMENT ON COLUMN person_discounts.discount IS 'discount for pair person and pizzeria';
        COMMENT ON TABLE person_discounts IS 'Discounts for persons';
    ELSE
        RAISE EXCEPTION 'Table person_discounts does not exist';
    END IF;
END $$;

SELECT COUNT(*) = 5 AS check
FROM pg_description
WHERE objoid = 'person_discounts'::regclass;
```

**Плюсы:**
- Безопасно (проверяет существование)

**Минусы:**
- Избыточно (COMMENT ON сам выдаст ошибку, если таблицы нет)

---

### Способ 8: С форматированием (многострочные комментарии)

```sql
COMMENT ON TABLE person_discounts IS 
'Personal discounts table.

Stores individual discount percentages for each customer-pizzeria pair.
One customer can have different discounts in different pizzerias.

Business rules:
- Discount range: 0-100%
- Unique constraint on (person_id, pizzeria_id)';

COMMENT ON COLUMN person_discounts.discount IS 
'Discount percentage (0-100).
Examples: 10.5 = 10.5% off, 22 = 22% off';

-- Остальные комментарии как в оригинале
```

**Плюсы:**
- Очень подробная документация
- Объясняет правила

**Минусы:**
- Может быть слишком длинно

---

## СРАВНЕНИЕ СПОСОБОВ

| Способ | Читаемость | Соответствие заданию | Подробность | Рекомендация |
|--------|------------|---------------------|-------------|--------------|
| **Оригинал (английский)** | Отличная | ✓ Полное | Достаточная | ✓ Лучший |
| **Русские комментарии** | Отличная | ✓ Полное | Достаточная | Для русской команды |
| **Детальные** | Хорошая | ✓ Полное | Высокая | Для сложных проектов |
| **С схемой public** | Отличная | ✓ Полное | Достаточная | Для multi-schema |
| **DO блок** | Плохая | ✓ Полное | Достаточная | ❌ Избыточно |
| **С удалением** | Хорошая | ✓ Полное | Достаточная | Избыточно |
| **information_schema** | Средняя | ✗ Может не работать | Достаточная | ❌ Ненадежно |
| **С проверкой таблицы** | Средняя | ✓ Полное | Достаточная | Избыточно |
| **Многострочные** | Отличная | ✓ Полное | Очень высокая | Для документации |

---

## РЕКОМЕНДАЦИЯ ДЛЯ ЗАЩИТЫ

**Оригинальный способ — правильный выбор**, потому что:
1. Соответствует требованиям (комментарии на английском)
2. Краткие и понятные описания
3. Простой и читаемый код
4. Стандартный подход в PostgreSQL

**Если спросят "зачем нужны комментарии?":**
> "Комментарии — это часть Data Governance (управления данными). Они документируют структуру базы для других разработчиков и объясняют бизнес-логику. Например, комментарий 'discount for pair person and pizzeria' объясняет, что скидка индивидуальная для каждой пары клиент-пиццерия."

**Если спросят "что такое ::regclass?":**
> "::regclass — это специальный тип данных PostgreSQL, который преобразует имя таблицы в её внутренний ID. PostgreSQL хранит объекты с числовыми ID, а ::regclass позволяет искать по имени вместо ID."

**Если спросят "почему проверяем COUNT(*) = 5?":**
> "Мы добавили 5 комментариев: 1 для таблицы и 4 для столбцов. Проверка подтверждает, что все комментарии успешно сохранены в системной таблице pg_description."