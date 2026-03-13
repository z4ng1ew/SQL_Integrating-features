DROP INDEX IF EXISTS idx_menu_unique;
CREATE UNIQUE INDEX idx_menu_unique ON menu (
    pizzeria_id,
    pizza_name
);

SET enable_seqscan = OFF;

EXPLAIN ANALYSE
SELECT *
FROM menu
WHERE pizzeria_id = 1 
  AND pizza_name = 'cheese pizza';












-- Удаляем уникальный индекс idx_menu_unique, если он существует (для идемпотентности)
DROP INDEX IF EXISTS idx_menu_unique;

-- Создаём УНИКАЛЬНЫЙ многоколоночный B-Tree индекс на таблице menu
-- UNIQUE - гарантирует отсутствие дубликатов по комбинации (pizzeria_id, pizza_name)
-- Это означает: в одной пиццерии (pizzeria_id) НЕ может быть двух пицц с одинаковым названием (pizza_name)
-- Например, в Pizza Hut не может быть две пиццы "Margherita"
-- Но в РАЗНЫХ пиццериях МОЖЕТ быть пицца с одинаковым названием (Pizza Hut: Margherita, Domino's: Margherita)
-- Индекс включает ДВА столбца в порядке: pizzeria_id, pizza_name
-- Порядок важен: работает для WHERE по pizzeria_id или по (pizzeria_id, pizza_name), но НЕ по одному pizza_name
CREATE UNIQUE INDEX idx_menu_unique ON menu (
    pizzeria_id,   -- первый столбец индекса (внешний ключ на таблицу pizzeria)
    pizza_name     -- второй столбец индекса (название пиццы)
);

-- Отключаем последовательное сканирование таблицы
-- Принудительно заставляет PostgreSQL использовать индекс idx_menu_unique
-- Необходимо для демонстрации работы индекса в учебных целях
SET enable_seqscan = OFF;

-- EXPLAIN ANALYSE показывает план выполнения и доказывает использование индекса
-- Ожидается увидеть: "Index Scan using idx_menu_unique" или "Index Only Scan using idx_menu_unique"
-- В данном случае будет Index Scan (не Index Only Scan), т.к. SELECT * включает столбцы id и price,
-- которых НЕТ в индексе → PostgreSQL вынужден обращаться к таблице за этими столбцами
EXPLAIN ANALYSE
-- SELECT * - выбираем ВСЕ столбцы: id, pizzeria_id, pizza_name, price
-- Столбцы id и price НЕ входят в индекс → будет Index Scan, а не Index Only Scan
SELECT *
FROM menu
-- Условие WHERE использует ОБА столбца индекса в правильном порядке
-- pizzeria_id = 1 - первый столбец индекса (используется для быстрого поиска)
-- pizza_name = 'cheese pizza' - второй столбец индекса (уточняет поиск)
-- Индекс эффективно работает, т.к. условия идут слева направо по столбцам индекса
-- Благодаря UNIQUE, PostgreSQL знает: максимум ОДНА строка может соответствовать условию
WHERE pizzeria_id = 1 
  AND pizza_name = 'cheese pizza';


---

## Дополнительные пояснения для защиты

### 1. Что такое UNIQUE INDEX?

**UNIQUE INDEX** = индекс, который **запрещает дубликаты**


-- БЕЗ уникального индекса - можно вставить дубликаты
INSERT INTO menu (pizzeria_id, pizza_name, price) VALUES (1, 'Margherita', 10);
INSERT INTO menu (pizzeria_id, pizza_name, price) VALUES (1, 'Margherita', 12); -- ОК ✅

-- С уникальным индексом - дубликаты запрещены
CREATE UNIQUE INDEX idx_menu_unique ON menu (pizzeria_id, pizza_name);
INSERT INTO menu (pizzeria_id, pizza_name, price) VALUES (1, 'Margherita', 10); -- ОК ✅
INSERT INTO menu (pizzeria_id, pizza_name, price) VALUES (1, 'Margherita', 12); -- ОШИБКА! ❌
-- ERROR: duplicate key value violates unique constraint "idx_menu_unique"
```

---

### 2. Зачем нужна уникальность по (pizzeria_id, pizza_name)?

**Бизнес-правило:** В одной пиццерии не должно быть двух пицц с одинаковым названием

```
Правильно:
Pizza Hut (pizzeria_id=1):
  - Margherita (цена 10)
  - Pepperoni (цена 12)

Domino's (pizzeria_id=2):
  - Margherita (цена 11)  ← ОК! Другая пиццерия ✅
  - Hawaiian (цена 13)

НЕПРАВИЛЬНО:
Pizza Hut (pizzeria_id=1):
  - Margherita (цена 10)
  - Margherita (цена 12)  ← ОШИБКА! Две пиццы с одинаковым названием в одной пиццерии! ❌
```

**UNIQUE INDEX (pizzeria_id, pizza_name)** обеспечивает это правило на уровне базы данных!

---

### 3. Почему порядок столбцов (pizzeria_id, pizza_name)?


CREATE UNIQUE INDEX idx_menu_unique ON menu (pizzeria_id, pizza_name);
```

**Порядок выбран для типичного сценария поиска:**

Чаще всего ищут: "Покажи меню конкретной пиццерии, найди конкретную пиццу"


-- ✅ Эффективно работает (используется индекс)
SELECT * FROM menu WHERE pizzeria_id = 1 AND pizza_name = 'Margherita';

-- ✅ Работает (используется индекс для pizzeria_id)
SELECT * FROM menu WHERE pizzeria_id = 1;

-- ❌ НЕ эффективно (нарушено правило левого префикса)
SELECT * FROM menu WHERE pizza_name = 'Margherita';
-- Пропущен первый столбец pizzeria_id → бинарный поиск не работает
```

---

### 4. Index Scan vs Index Only Scan в этом запросе


-- Индекс содержит ТОЛЬКО: (pizzeria_id, pizza_name)
CREATE UNIQUE INDEX idx_menu_unique ON menu (pizzeria_id, pizza_name);

-- SELECT * выбирает ВСЕ столбцы: id, pizzeria_id, pizza_name, price
SELECT *
FROM menu
WHERE pizzeria_id = 1 AND pizza_name = 'cheese pizza';
```

**Что произойдёт:**

1. PostgreSQL использует индекс для поиска → находит строку
2. **НО** в индексе нет столбцов `id` и `price`
3. PostgreSQL вынужден обратиться к таблице за недостающими столбцами
4. Результат: **Index Scan** (не Index Only Scan)

**Если бы хотели Index Only Scan:**
```sql
-- Нужно выбирать ТОЛЬКО столбцы из индекса
SELECT pizzeria_id, pizza_name
FROM menu
WHERE pizzeria_id = 1 AND pizza_name = 'cheese pizza';
-- Теперь Index Only Scan ✅
```

---

### 5. Преимущества UNIQUE индекса

**Двойная польза:**
1. ✅ **Ускоряет поиск** (как обычный индекс)
2. ✅ **Гарантирует уникальность** (защита данных от дубликатов)

```sql
-- PostgreSQL автоматически использует UNIQUE для оптимизации
SELECT * FROM menu WHERE pizzeria_id = 1 AND pizza_name = 'Margherita';
-- PostgreSQL знает: благодаря UNIQUE максимум 1 строка → может остановиться после первого совпадения
```

---

### 6. Отличие UNIQUE INDEX от обычного INDEX

| Характеристика | Обычный INDEX | UNIQUE INDEX |
|----------------|---------------|--------------|
| **Ускоряет поиск** | ✅ Да | ✅ Да |
| **Разрешает дубликаты** | ✅ Да | ❌ Нет |
| **Защита данных** | ❌ Нет | ✅ Да |
| **Использование** | Для ускорения | Для ускорения + гарантия уникальности |

---

## Итог для защиты

**Вопрос:** Чем отличается UNIQUE INDEX от обычного INDEX?

**Ответ:**
1. UNIQUE INDEX **запрещает дубликаты** по указанным столбцам
2. Обычный INDEX просто ускоряет поиск
3. В нашем случае UNIQUE INDEX гарантирует: в одной пиццерии не может быть двух пицц с одинаковым названием
4. Комбинация (pizzeria_id=1, pizza_name='Margherita') может встретиться **только один раз**
5. Но (pizzeria_id=2, pizza_name='Margherita') разрешена (другая пиццерия)

**Вопрос:** Почему SELECT * не даёт Index Only Scan?

**Ответ:**
1. Индекс содержит только (pizzeria_id, pizza_name)
2. SELECT * запрашивает также id и price
3. PostgreSQL находит строку через индекс, но потом идёт в таблицу за остальными столбцами
4. Поэтому Index Scan, а не Index Only Scan

































## Index Scan vs Index Only Scan

Это **ДВА РАЗНЫХ** способа использования индекса!

---

## Index Scan (обычное сканирование индекса)

**Index Scan** = смотрим в индекс + идём в таблицу

### Аналогия - библиотека с каталогом

```
Задача: Найти книгу "Война и мир" и узнать год издания

Шаг 1: Смотришь в КАТАЛОГ (индекс)
       "Война и мир" → полка 5, место 23
       
Шаг 2: Идёшь к ПОЛКЕ 5 (таблица)
       Берёшь книгу
       Смотришь год издания → 1869

Итого: 2 действия (каталог + полка)
```

### В базе данных

```
Таблица person:
id | name   | age | address
---|--------|-----|----------
5  | Kate   | 25  | Moscow
10 | John   | 30  | Paris

Индекс по name:
name   → указатель
-------|------------
John   → строка 10
Kate   → строка 5

Запрос:
SELECT * FROM person WHERE name = 'Kate';

Шаг 1: PostgreSQL смотрит в ИНДЕКС
       "Kate" → указатель на строку 5
       
Шаг 2: PostgreSQL идёт в ТАБЛИЦУ
       Читает строку 5
       Берёт: id=5, name='Kate', age=25, address='Moscow'

Результат: Index Scan (2 операции чтения)
```

---

## Index Only Scan (сканирование ТОЛЬКО индекса)

**Index Only Scan** = смотрим ТОЛЬКО в индекс, таблицу НЕ читаем

### Аналогия - подробный каталог

```
Задача: Найти автора книги "Война и мир"

Шаг 1: Смотришь в ПОДРОБНЫЙ КАТАЛОГ (индекс с доп. данными)
       "Война и мир" → автор: Толстой Л.Н.
       
Всё! Информация уже в каталоге!
(НЕ нужно идти к полке)

Итого: 1 действие (только каталог)
```

### В базе данных

```
Таблица person:
id | name   | age | address
---|--------|-----|----------
5  | Kate   | 25  | Moscow
10 | John   | 30  | Paris

Многоколоночный индекс (name, age):
name   | age  → указатель
-------|------|------------
John   | 30   → строка 10
Kate   | 25   → строка 5

Запрос:
SELECT name, age FROM person WHERE name = 'Kate';

Шаг 1: PostgreSQL смотрит в ИНДЕКС
       "Kate" → name='Kate', age=25
       ВСЁ! Все нужные данные УЖЕ в индексе!

~~Шаг 2: Таблицу НЕ читаем~~

Результат: Index Only Scan (1 операция чтения) → в 2 раза быстрее!
```

---

## Визуальное сравнение

### Index Scan:

```
┌─────────────┐
│   Индекс    │
│ name → ptr  │  ← Шаг 1: Смотрим индекс
│ Kate → 5    │
└──────┬──────┘
       │
       ↓ (идём по указателю)
       │
┌──────┴─────────────────────┐
│        Таблица             │
│ id|name |age|address       │  ← Шаг 2: Читаем таблицу
│ 5 |Kate |25 |Moscow        │
└────────────────────────────┘

Итого: 2 чтения
```

### Index Only Scan:

```
┌──────────────────────┐
│   Индекс (name, age) │
│ name | age  → ptr    │  ← Шаг 1: Смотрим индекс
│ Kate | 25  → 5       │     ВСЁ ЗДЕСЬ! Таблицу не читаем!
└──────────────────────┘

┌────────────────────────────┐
│        Таблица             │
│ id|name |age|address       │  ← Шаг 2: НЕ используется! ✅
│ 5 |Kate |25 |Moscow        │
└────────────────────────────┘

Итого: 1 чтение (быстрее!)
```

---

## Ключевое отличие

| Характеристика | Index Scan | Index Only Scan |
|----------------|------------|-----------------|
| **Читаем индекс** | ✅ Да | ✅ Да |
| **Читаем таблицу** | ✅ Да | ❌ НЕТ |
| **Количество операций** | 2 | 1 |
| **Скорость** | Быстро | **В 2 раза быстрее** |
| **Условие** | Любой запрос | SELECT только столбцы из индекса |

---

## Когда работает Index Only Scan?

### Правило: SELECT должен содержать ТОЛЬКО столбцы из индекса!

```sql
-- Индекс содержит (name, age)
CREATE INDEX idx ON person (name, age);

-- ✅ Index Only Scan (все столбцы в индексе)
SELECT name, age 
FROM person 
WHERE name = 'Kate';

-- ✅ Index Only Scan (только name из индекса)
SELECT name 
FROM person 
WHERE name = 'Kate';

-- ❌ Index Scan (столбец address НЕТ в индексе!)
SELECT name, age, address 
FROM person 
WHERE name = 'Kate';

-- ❌ Index Scan (столбец id НЕТ в индексе!)
SELECT * 
FROM person 
WHERE name = 'Kate';
```

---

## Примеры из заданий

### Задание 03: Index Only Scan ✅

```sql
CREATE INDEX idx ON person_order (person_id, menu_id, order_date);

SELECT person_id, menu_id, order_date  -- ВСЕ столбцы в индексе!
FROM person_order
WHERE person_id = 8 AND menu_id = 19;

→ Index Only Scan ✅
```

**Почему?**
- SELECT запрашивает: person_id, menu_id, order_date
- Индекс содержит: person_id, menu_id, order_date
- ✅ Все столбцы есть → Index Only Scan!

---

### Задание 04: Index Scan (не Only!) ❌

```sql
CREATE UNIQUE INDEX idx ON menu (pizzeria_id, pizza_name);

SELECT *  -- Запрашивает ВСЕ столбцы: id, pizzeria_id, pizza_name, price
FROM menu
WHERE pizzeria_id = 1 AND pizza_name = 'cheese pizza';

→ Index Scan (не Index Only Scan)
```

**Почему?**
- SELECT * запрашивает: id, pizzeria_id, pizza_name, price
- Индекс содержит: pizzeria_id, pizza_name
- ❌ Столбцов id и price нет в индексе → нужно читать таблицу → Index Scan

---

## Аналогия из реальной жизни

### Index Scan = двухэтапный поиск

```
Ищешь номер телефона друга:

1. Смотришь в телефонную книгу → "Иванов Петр, стр. 45"
2. Открываешь страницу 45 → смотришь полную информацию

2 действия
```

### Index Only Scan = всё в одном месте

```
Ищешь номер телефона друга:

1. Смотришь в телефонную книгу → "Иванов Петр: +7-123-456"
   Номер УЖЕ написан рядом с именем!

1 действие (быстрее!)
```

---

## Как PostgreSQL решает, что использовать?

```
PostgreSQL смотрит на запрос:

1. Есть ли индекс для WHERE?
   Нет → Sequential Scan
   Да → переход к шагу 2

2. Все ли столбцы SELECT есть в индексе?
   Да → Index Only Scan ✅ (супер быстро!)
   Нет → Index Scan (быстро, но медленнее)
```

---

## Итог простыми словами

**Index Scan** = "Смотрю каталог → иду к полке"  
(2 операции: индекс + таблица)

**Index Only Scan** = "Смотрю каталог → всё уже там!"  
(1 операция: только индекс, быстрее в 2 раза!)

**Условие для Index Only Scan:**  
SELECT должен запрашивать **ТОЛЬКО** те столбцы, которые есть в индексе!

---

## Что быстрее?

```
Sequential Scan (без индекса):  🐌🐌🐌 (медленно)
Index Scan (с индексом):         🚗 (быстро)
Index Only Scan (с индексом):    🚀 (супер быстро!)
```

Понятнее теперь? 🙂