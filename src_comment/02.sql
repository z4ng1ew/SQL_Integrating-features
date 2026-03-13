DROP INDEX IF EXISTS idx_person_name;
CREATE INDEX idx_person_name ON person (UPPER(name));

SET enable_seqscan = OFF;

EXPLAIN ANALYSE
SELECT *
FROM person
WHERE UPPER(name) = 'Kate';














-- Удаляем индекс idx_person_name, если он существует (для идемпотентности)
DROP INDEX IF EXISTS idx_person_name;

-- Создаём ФУНКЦИОНАЛЬНЫЙ B-Tree индекс по столбцу name таблицы person
-- Особенность: индекс создаётся не по самому столбцу name, а по результату функции UPPER(name)
-- UPPER(name) - преобразует имя в верхний регистр (Kate → KATE, john → JOHN)
-- Это позволяет делать регистронезависимый поиск быстро через индекс
CREATE INDEX idx_person_name ON person (UPPER(name));

-- Отключаем последовательное сканирование таблицы
-- Принудительно заставляет PostgreSQL использовать функциональный индекс
-- Необходимо для демонстрации работы индекса в учебных целях
SET enable_seqscan = OFF;

-- Команда EXPLAIN ANALYSE показывает план выполнения и реальную статистику
-- Позволяет убедиться, что индекс idx_person_name действительно используется
EXPLAIN ANALYSE
-- Выбираем все столбцы из таблицы person
SELECT *
FROM person
-- КРИТИЧЕСКИ ВАЖНО: в условии WHERE используем ту же функцию UPPER(), 
-- что и при создании индекса
-- Если бы написали просто "name = 'Kate'", индекс НЕ использовался бы!
-- PostgreSQL сопоставляет UPPER(name) в WHERE с UPPER(name) в индексе → использует индекс
WHERE UPPER(name) = 'Kate';


---

## Дополнительное объяснение для защиты:

### Почему нужен функциональный индекс?

**Проблема без функционального индекса:**

-- Обычный индекс
CREATE INDEX idx_person_name_simple ON person (name);

-- Этот запрос НЕ использует индекс!
SELECT * FROM person WHERE UPPER(name) = 'Kate';
-- Причина: индекс хранит 'Kate', 'Anna', 'John'
--          но WHERE ищет по UPPER(name) = 'KATE', 'ANNA', 'JOHN'
--          PostgreSQL не может сопоставить!


**Решение - функциональный индекс:**

-- Индекс хранит уже преобразованные значения
CREATE INDEX idx_person_name ON person (UPPER(name));
-- Индекс содержит: 'KATE', 'ANNA', 'JOHN' (всё в верхнем регистре)

-- Теперь этот запрос ИСПОЛЬЗУЕТ индекс!
SELECT * FROM person WHERE UPPER(name) = 'Kate';
-- WHERE приводит 'Kate' → 'KATE' 
-- Индекс содержит 'KATE' → быстрый поиск!


---

### Золотое правило функциональных индексов:

**Функция в индексе = Функция в WHERE**

CREATE INDEX idx ON table (UPPER(column));  -- функция UPPER
SELECT * FROM table WHERE UPPER(column) = ...; -- та же UPPER ✅

CREATE INDEX idx ON table (UPPER(column));  -- функция UPPER
SELECT * FROM table WHERE column = ...; -- нет UPPER ❌ индекс не работает!

























функциональный B-Tree index  - ЧЕМ ОТЛИЧАЕТСЯ ОТ простой BTree index



## Отличие функционального индекса от простого

### Простой B-Tree индекс

**Хранит копию значений "как есть":**


-- Простой индекс
CREATE INDEX idx_person_name_simple ON person (name);
```

**Что хранится в индексе:**
```
Таблица person:
id | name
---|------
1  | Kate
2  | Anna
3  | John

Индекс idx_person_name_simple:
'Anna' → указатель на строку 2
'John' → указатель на строку 3
'Kate' → указатель на строку 1
(отсортировано, но ТОЧНО как в таблице)
```

---

### Функциональный B-Tree индекс

**Хранит результат ПРИМЕНЕНИЯ ФУНКЦИИ к значениям:**

```sql
-- Функциональный индекс
CREATE INDEX idx_person_name ON person (UPPER(name));
```

**Что хранится в индексе:**
```
Таблица person (не изменилась):
id | name
---|------
1  | Kate
2  | Anna
3  | John

Индекс idx_person_name (функциональный):
'ANNA' → указатель на строку 2
'JOHN' → указатель на строку 3
'KATE' → указатель на строку 1
(хранятся УЖЕ ПРЕОБРАЗОВАННЫЕ значения!)
```

---

## Аналогия из жизни

### Простой индекс = обычный телефонный справочник

```
Справочник:
Иванов Пётр → тел. 123
Смирнов Иван → тел. 456
Яковлев Андрей → тел. 789

Можешь найти только точное совпадение:
"Иванов Пётр" ✅ найдёт
"иванов пётр" ❌ не найдёт (другой регистр!)
"ИВАНОВ ПЁТР" ❌ не найдёт
```

### Функциональный индекс = справочник с нормализацией

```
Справочник (все имена приведены к ЗАГЛАВНЫМ):
ИВАНОВ ПЁТР → тел. 123
СМИРНОВ ИВАН → тел. 456
ЯКОВЛЕВ АНДРЕЙ → тел. 789

Теперь можешь искать в любом регистре:
"Иванов Пётр" → преобразуется в "ИВАНОВ ПЁТР" ✅ найдёт
"иванов пётр" → преобразуется в "ИВАНОВ ПЁТР" ✅ найдёт
"ИВАНОВ ПЁТР" → уже в нужном виде ✅ найдёт
```

---

## Ключевые отличия в таблице

| Характеристика | Простой индекс | Функциональный индекс |
|----------------|----------------|----------------------|
| **Что хранит** | Копию значений столбца | Результат функции от значений |
| **Пример** | `'Kate'` | `'KATE'` (результат UPPER) |
| **Когда работает** | `WHERE name = 'Kate'` | `WHERE UPPER(name) = 'Kate'` |
| **Размер** | Обычный | Может быть больше/меньше в зависимости от функции |
| **Применение** | Прямой поиск точных значений | Поиск с преобразованиями |

---

## Примеры использования

### 1. Простой индекс - для точного поиска

```sql
CREATE INDEX idx_simple ON person (name);

-- Работает ✅
SELECT * FROM person WHERE name = 'Kate';

-- НЕ работает ❌ (функция в WHERE, но не в индексе)
SELECT * FROM person WHERE UPPER(name) = 'KATE';

-- НЕ работает ❌ (другой регистр)
SELECT * FROM person WHERE name = 'kate';
```

### 2. Функциональный индекс - для поиска с преобразованием

```sql
CREATE INDEX idx_functional ON person (UPPER(name));

-- Работает ✅ (та же функция UPPER в WHERE)
SELECT * FROM person WHERE UPPER(name) = 'KATE';
SELECT * FROM person WHERE UPPER(name) = 'Kate'; -- 'Kate' → 'KATE' ✅

-- НЕ работает ❌ (нет функции UPPER в WHERE)
SELECT * FROM person WHERE name = 'Kate';
```

---

## Другие примеры функциональных индексов

```sql
-- 1. Индекс по первым 3 символам (для поиска по префиксу)
CREATE INDEX idx_prefix ON person (LEFT(name, 3));
-- Использование:
SELECT * FROM person WHERE LEFT(name, 3) = 'Kat';

-- 2. Индекс по дате без времени (для поиска по дню)
CREATE INDEX idx_date_only ON person_order (DATE(order_date));
-- Использование:
SELECT * FROM person_order WHERE DATE(order_date) = '2022-01-01';

-- 3. Индекс по длине строки
CREATE INDEX idx_name_length ON person (LENGTH(name));
-- Использование:
SELECT * FROM person WHERE LENGTH(name) = 4;

-- 4. Индекс по вычисляемому значению
CREATE INDEX idx_total_price ON person_order ((price * quantity));
-- Использование:
SELECT * FROM person_order WHERE (price * quantity) > 100;
```

---

## Когда использовать какой индекс?

### Простой индекс:
- ✅ Обычный поиск по точному значению
- ✅ Сортировка
- ✅ Простые сравнения (`=`, `>`, `<`)

### Функциональный индекс:
- ✅ Регистронезависимый поиск (`UPPER`, `LOWER`)
- ✅ Поиск по части строки (`LEFT`, `RIGHT`, `SUBSTRING`)
- ✅ Поиск по вычисляемым значениям (`price * quantity`)
- ✅ Поиск по датам без времени (`DATE()`)
- ✅ Поиск с нормализацией данных

---

## Важное правило!

```sql
-- Если создал функциональный индекс:
CREATE INDEX idx ON table (UPPER(column));

-- ОБЯЗАТЕЛЬНО используй ту же функцию в WHERE:
SELECT * FROM table WHERE UPPER(column) = 'VALUE'; ✅

-- Иначе индекс НЕ работает:
SELECT * FROM table WHERE column = 'VALUE'; ❌


---

## Итог

**Простой индекс** = фотография столбца "как есть"  
**Функциональный индекс** = фотография столбца "после обработки функцией"

Оба используют **одну структуру B-Tree**, отличие только в **содержимом индекса**!