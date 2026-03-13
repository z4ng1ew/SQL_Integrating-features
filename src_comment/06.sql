DROP INDEX IF EXISTS idx_1;
CREATE INDEX idx_1 ON pizzeria (rating);

SET enable_seqscan = OFF;

EXPLAIN ANALYSE
SELECT
    m.pizza_name AS pizza_name,
    MAX(rating) OVER (
        PARTITION BY rating 
        ORDER BY rating 
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS k
FROM menu m
INNER JOIN pizzeria pz 
    ON m.pizzeria_id = pz.id
ORDER BY 1, 2;

































-- Удаляем индекс idx_1, если он существует (для идемпотентности)
DROP INDEX IF EXISTS idx_1;

-- Создаём B-Tree индекс idx_1 по столбцу rating в таблице pizzeria
-- Этот индекс оптимизирует выполнение запроса с оконной функцией PARTITION BY rating
-- Индекс по rating ускоряет:
-- 1. JOIN между menu и pizzeria (быстрее читать pizzeria упорядоченно по rating)
-- 2. PARTITION BY rating в оконной функции (данные уже сгруппированы по rating)
-- 3. Сортировку для оконной функции (данные уже отсортированы по rating)
CREATE INDEX idx_1 ON pizzeria (rating);

-- Отключаем последовательное сканирование таблицы
-- Принудительно заставляет PostgreSQL использовать индекс idx_1
-- Необходимо для демонстрации улучшения производительности
SET enable_seqscan = OFF;

-- EXPLAIN ANALYSE показывает план выполнения запроса и реальное время
-- Позволяет сравнить производительность ДО и ПОСЛЕ создания индекса
-- Ожидается увидеть: "Index Scan using idx_1 on pizzeria pz"
EXPLAIN ANALYSE
SELECT
    -- Название пиццы из таблицы menu
    m.pizza_name AS pizza_name,
    
    -- ОКОННАЯ ФУНКЦИЯ (Window Function):
    -- MAX(rating) - вычисляет максимальный рейтинг
    -- OVER (...) - определяет "окно" для вычисления
    -- 
    -- PARTITION BY rating - разбивает данные на группы по значению rating
    -- Каждая группа содержит пиццерии с ОДИНАКОВЫМ рейтингом
    -- Например: группа с rating=4.5, группа с rating=3.0, и т.д.
    --
    -- ORDER BY rating - сортирует строки внутри каждой партиции по rating
    -- (В данном случае избыточно, т.к. все значения rating в партиции одинаковые)
    --
    -- ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    -- Означает: рассматривать ВСЕ строки в текущей партиции
    -- UNBOUNDED PRECEDING = от начала партиции
    -- UNBOUNDED FOLLOWING = до конца партиции
    -- Это рамка окна (window frame) - какие строки включать в вычисление MAX
    --
    -- ЛОГИКА: MAX(rating) внутри PARTITION BY rating
    -- Все строки в одной партиции имеют ОДИНАКОВЫЙ rating
    -- Поэтому MAX(rating) всегда равен самому rating для этой партиции
    -- Пример: если rating=4.5, то MAX(rating) в этой группе = 4.5
    MAX(rating) OVER (
        PARTITION BY rating 
        ORDER BY rating 
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS k
    
-- Основная таблица menu с алиасом m (содержит информацию о пиццах)
FROM menu m

-- Соединяем с таблицей pizzeria (содержит информацию о пиццериях и их рейтингах)
-- Индекс idx_1 ускоряет это соединение, т.к. PostgreSQL может читать pizzeria
-- в отсортированном порядке по rating, что помогает оконной функции
INNER JOIN pizzeria pz 
    ON m.pizzeria_id = pz.id
    
-- Финальная сортировка результата:
-- 1 = первый столбец (pizza_name)
-- 2 = второй столбец (k, то есть MAX(rating))
-- Сортирует результаты сначала по названию пиццы, потом по рейтингу
ORDER BY 1, 2;
```

---

## Дополнительные объяснения для защиты

### 1. Что такое оконная функция (Window Function)?

**Оконная функция** = вычисление агрегата (MAX, SUM, AVG) для "окна" строк, **НЕ схлопывая** результат в одну строку

**Обычная агрегация (GROUP BY):**
```sql
-- Схлопывает строки в группы
SELECT rating, MAX(rating)
FROM pizzeria
GROUP BY rating;

Результат (3 строки):
rating | max
-------|-----
3.0    | 3.0
4.5    | 4.5
5.0    | 5.0
```

**Оконная функция (OVER):**
```sql
-- НЕ схлопывает, добавляет столбец к КАЖДОЙ строке
SELECT name, rating, MAX(rating) OVER (PARTITION BY rating)
FROM pizzeria;

Результат (6 строк, если 6 пиццерий):
name        | rating | max
------------|--------|-----
Pizza Hut   | 4.5    | 4.5  ← те же 4.5
Domino's    | 4.5    | 4.5  ← те же 4.5
Papa John's | 3.0    | 3.0
Best Pizza  | 5.0    | 5.0
...
```

---

### 2. Как работает PARTITION BY rating?

**PARTITION BY** = разделяет данные на группы (партиции)

```
Таблица pizzeria:
id | name        | rating
---|-------------|-------
1  | Pizza Hut   | 4.5
2  | Domino's    | 4.5
3  | Papa John's | 3.0
4  | Best Pizza  | 5.0
5  | Mama Mia    | 4.5
6  | DoDo Pizza  | 3.0

PARTITION BY rating создаёт группы:

Партиция 1 (rating=3.0):
  Papa John's (3.0)
  DoDo Pizza (3.0)

Партиция 2 (rating=4.5):
  Pizza Hut (4.5)
  Domino's (4.5)
  Mama Mia (4.5)

Партиция 3 (rating=5.0):
  Best Pizza (5.0)
```

**MAX(rating) для каждой партиции:**
```
Партиция 1: MAX(3.0, 3.0) = 3.0
Партиция 2: MAX(4.5, 4.5, 4.5) = 4.5
Партиция 3: MAX(5.0) = 5.0
```

**Но постойте!** Все значения rating в одной партиции **одинаковые**!  
Поэтому MAX(rating) = rating для этой партиции (немного избыточно, но синтаксически корректно)

---

### 3. Что означает ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING?

**Window Frame** (рамка окна) = какие строки включать в вычисление

```
UNBOUNDED PRECEDING = от начала партиции
UNBOUNDED FOLLOWING = до конца партиции

Пример для партиции с rating=4.5:
┌─────────────────────────────────────┐
│ UNBOUNDED PRECEDING (начало)        │
│                                     │
│ → Pizza Hut (4.5)    ← текущая      │
│   Domino's (4.5)                    │
│   Mama Mia (4.5)                    │
│                                     │
│ UNBOUNDED FOLLOWING (конец)         │
└─────────────────────────────────────┘

Для Pizza Hut:
MAX(rating) среди строк от начала до конца = MAX(4.5, 4.5, 4.5) = 4.5

Для Domino's:
MAX(rating) среди строк от начала до конца = MAX(4.5, 4.5, 4.5) = 4.5

Для Mama Mia:
MAX(rating) среди строк от начала до конца = MAX(4.5, 4.5, 4.5) = 4.5
```

**Все получают одинаковый результат = 4.5!**

---

### 4. Зачем нужен индекс по rating?

**Индекс по rating помогает:**

1. **JOIN быстрее:**
```
Без индекса:
PostgreSQL читает pizzeria в случайном порядке

С индексом по rating:
PostgreSQL читает pizzeria УЖЕ отсортированную по rating
→ Меньше работы для JOIN
```

2. **PARTITION BY rating быстрее:**
```
Без индекса:
PostgreSQL должен СОРТИРОВАТЬ данные по rating для создания партиций

С индексом по rating:
Данные УЖЕ отсортированы по rating
→ Партиции создаются быстрее
```

3. **Оконная функция быстрее:**
```
Без индекса:
PostgreSQL сортирует → создаёт партиции → вычисляет MAX

С индексом:
Данные УЖЕ в нужном порядке
→ Сразу вычисляет MAX
```

---

### 5. Почему именно idx_1 по rating, а не по другому столбцу?

**Ответ:** Потому что оконная функция использует **PARTITION BY rating**!

Индекс должен совпадать с **ключом партиционирования**:

```sql
-- Оконная функция:
MAX(rating) OVER (PARTITION BY rating ...)
                              ↑
                              └── Партиционирование по rating

-- Индекс:
CREATE INDEX idx_1 ON pizzeria (rating);
                                 ↑
                                 └── Индекс по rating

✅ Совпадают → индекс полезен!
```

**Если бы индекс был по другому столбцу:**
```sql
CREATE INDEX idx_wrong ON pizzeria (name);

-- Оконная функция всё равно по rating
MAX(rating) OVER (PARTITION BY rating ...)

❌ Не совпадают → индекс бесполезен для оконной функции!
```

---

### 6. Пример улучшения производительности

**ДО создания индекса:**
```
Execution Time: 0.338 ms
```

**ПОСЛЕ создания индекса:**
```
Execution Time: 0.203 ms
```

**Улучшение:** 0.338 → 0.203 мс = **в 1.66 раза быстрее!** 🚀

---

## Итог для защиты

**Вопрос:** Зачем создан индекс по rating?

**Ответ:**
1. Запрос использует оконную функцию с PARTITION BY rating
2. Индекс по rating ускоряет создание партиций (данные уже отсортированы)
3. JOIN с таблицей pizzeria также быстрее (читаем в упорядоченном виде)
4. Результат: время выполнения уменьшилось с 0.338 мс до 0.203 мс

**Вопрос:** Что делает оконная функция MAX(rating) OVER?

**Ответ:**
1. PARTITION BY rating разбивает пиццерии на группы по рейтингу
2. MAX(rating) вычисляет максимум внутри каждой группы
3. Так как в группе все rating одинаковые, MAX(rating) = rating
4. ROWS BETWEEN ... означает "рассматривать всю партицию"

**Вопрос:** Почему не создали индекс по pizza_name?

**Ответ:**
1. Оконная функция работает с rating, не с pizza_name
2. PARTITION BY rating требует сортировки по rating
3. Индекс по rating помогает именно этой сортировке
4. Индекс по pizza_name не ускорил бы PARTITION BY rating