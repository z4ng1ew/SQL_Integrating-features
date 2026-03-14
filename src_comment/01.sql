DELETE FROM person_discounts;

INSERT INTO person_discounts (id, person_id, pizzeria_id, discount)
SELECT
    ROW_NUMBER() OVER () AS id,
    person_id,
    menu.pizzeria_id,
    CASE
        WHEN COUNT(*) = 1 THEN 10.5
        WHEN COUNT(*) = 2 THEN 22
        ELSE 30
    END AS discount
FROM person_order 
    INNER JOIN menu 
        ON menu.id = person_order.menu_id
GROUP BY person_id, menu.pizzeria_id;

SELECT COUNT(*) > 0 AS check
FROM person_discounts;















 
-- Удаляем ВСЕ существующие записи из таблицы person_discounts
-- Это обеспечивает идемпотентность - можно запускать скрипт много раз, получая одинаковый результат
-- Если запустить скрипт повторно, старые данные не будут дублироваться
DELETE FROM person_discounts;

-- Вставляем новые записи в таблицу person_discounts
-- INSERT INTO ... SELECT - конструкция для массовой вставки данных из другой таблицы/запроса
INSERT INTO person_discounts (id, person_id, pizzeria_id, discount)

-- SELECT начинает запрос, который выберет данные для вставки
SELECT
    -- ROW_NUMBER() OVER () - оконная функция, генерирует уникальные порядковые номера
    -- Для каждой строки результата создается номер: 1, 2, 3, 4...
    -- OVER () - пустое окно означает "для всех строк подряд"
    -- AS id - присваиваем этому номеру имя "id" (будет первичным ключом)
    ROW_NUMBER() OVER () AS id,
    
    -- person_id - берем идентификатор человека из сгруппированных данных
    -- Это покажет, КТО получает скидку
    person_id,
    
    -- menu.pizzeria_id - берем идентификатор пиццерии из таблицы menu
    -- Это покажет, В КАКОЙ пиццерии человек получает скидку
    -- menu. - указываем явно, из какой таблицы берем столбец (для ясности)
    menu.pizzeria_id,
    
    -- CASE - условный оператор (аналог if-else в программировании)
    -- Рассчитываем процент скидки в зависимости от количества заказов
    CASE
        -- WHEN COUNT(*) = 1 - если количество заказов равно 1
        -- COUNT(*) подсчитывает количество строк в каждой группе (см. GROUP BY ниже)
        -- THEN 10.5 - то скидка = 10.5%
        WHEN COUNT(*) = 1 THEN 10.5
        
        -- WHEN COUNT(*) = 2 - если количество заказов равно 2
        -- THEN 22 - то скидка = 22%
        WHEN COUNT(*) = 2 THEN 22
        
        -- ELSE 30 - во всех остальных случаях (3 и более заказов)
        -- скидка = 30%
        ELSE 30
    -- END AS discount - завершаем CASE, результат называем "discount"
    END AS discount

-- FROM person_order - начинаем выборку из таблицы person_order (история заказов)
FROM person_order 

    -- INNER JOIN menu - объединяем (джойним) с таблицей menu
    -- INNER JOIN - берем только те строки, где есть совпадения в ОБЕИХ таблицах
    INNER JOIN menu 
        -- ON - условие соединения таблиц
        -- menu.id = person_order.menu_id - связываем по ключу:
        -- id блюда в меню равен menu_id в заказе
        ON menu.id = person_order.menu_id

-- GROUP BY - группируем данные (объединяем одинаковые строки)
-- Группируем по двум столбцам: person_id, menu.pizzeria_id
-- Это означает: "Объедини все заказы одного человека в одной пиццерии в одну строку"
-- Например, если Андрей делал 3 заказа в Dominos, они станут ОДНОЙ строкой
-- COUNT(*) будет работать внутри каждой группы - подсчитает количество заказов
GROUP BY person_id, menu.pizzeria_id;

-- Проверка успешности вставки данных
-- SELECT - запрос на выборку
-- COUNT(*) - подсчитываем общее количество строк в таблице person_discounts
-- > 0 - проверяем, что строк больше нуля (таблица НЕ пустая)
-- AS check - называем результат "check"
-- Результат должен быть "true" - это подтверждает, что данные успешно вставлены
SELECT COUNT(*) > 0 AS check
FROM person_discounts;
```

## Краткий пересказ для устной защиты:

**Строка 1-3**: Удаляю все старые записи из person_discounts, чтобы при повторном запуске скрипта не было дублей.

**Строка 5-6**: Начинаю массовую вставку данных - INSERT INTO ... SELECT позволяет вставить сразу много строк из результата запроса.

**Строка 9-11**: ROW_NUMBER() генерирует уникальные номера для столбца id - каждой строке присваивается порядковый номер 1, 2, 3...

**Строка 13-14**: Беру person_id - это покажет, кто получает скидку.

**Строка 16-18**: Беру pizzeria_id из таблицы menu - это покажет, в какой пиццерии действует скидка.

**Строки 20-28**: CASE - это условный оператор, как if-else в программировании. Рассчитываю процент скидки: 1 заказ = 10.5%, 2 заказа = 22%, 3+ заказов = 30%. COUNT(*) подсчитывает количество заказов в каждой группе.

**Строки 30-34**: Джойню таблицы person_order и menu - связываю заказы с блюдами из меню, чтобы узнать, в какой пиццерии был каждый заказ.

**Строка 36**: GROUP BY группирует данные по паре "человек + пиццерия". Например, если Андрей делал 5 заказов в Dominos, они станут одной строкой с COUNT(*) = 5.

**Строки 38-40**: Проверочный запрос - проверяю, что в таблице есть хотя бы одна запись, это подтверждает успешную вставку.
































## ЧТО ТАКОЕ ОКОННАЯ ФУНКЦИЯ?

**Оконная функция** (Window Function) — это функция, которая **смотрит на группу строк** (на "окно") и делает что-то с ними, НО **НЕ СКЛЕИВАЕТ** их в одну строку (в отличие от GROUP BY).

### Аналогия: Класс учеников

Представь класс из 5 учеников:

```
Имя    | Рост
-------|-----
Вася   | 160
Петя   | 175
Маша   | 165
Коля   | 170
Аня    | 158
```

### С GROUP BY (обычная группировка):

Если спросить "средний рост класса", получишь **ОДНУ** строку:
```
средний_рост
------------
165.6
```

Все ученики **ИСЧЕЗЛИ**, осталась только одна цифра.

### С ОКОННОЙ ФУНКЦИЕЙ:

Если спросить "каждому ученику присвой порядковый номер по росту", получишь **ВСЕ** строки:
```
Имя    | Рост | Номер_по_росту
-------|------|---------------
Аня    | 158  | 1  ← самая низкая
Вася   | 160  | 2
Маша   | 165  | 3
Коля   | 170  | 4
Петя   | 175  | 5  ← самый высокий
```

Все ученики **ОСТАЛИСЬ**, но у каждого появился номер.

## ROW_NUMBER() - ЧТО ЭТО?

**ROW_NUMBER()** — это оконная функция, которая **нумерует строки**: 1, 2, 3, 4, 5...

Как учитель, который выстраивает детей в шеренгу и говорит: "Ты первый, ты второй, ты третий..."

## СИНТАКСИС: ROW_NUMBER() OVER ()

```sql
ROW_NUMBER() OVER ()
     ↓         ↓
  "нумеруй"  "окно"
```

### ROW_NUMBER() = "нумеруй строки"

Это **название функции**. Она просто ставит номера: 1, 2, 3, 4...

### OVER () = "для какого окна?"

**OVER** (над) — ключевое слово, которое говорит "для какой группы строк работает функция".

**()** — пустые скобки означают "для ВСЕХ строк подряд, без разделения на группы".

## КАК ЭТО РАБОТАЕТ?

### Пример 1: ROW_NUMBER() OVER () — пустое окно

```sql
SELECT 
    name,
    ROW_NUMBER() OVER () AS номер
FROM person;
```

**Результат:**
```
name    | номер
--------|------
Андрей  | 1
Денис   | 2
Анна    | 3
Петя    | 4
```

PostgreSQL:
1. Берет **ВСЕ** строки
2. Присваивает номер **ПОДРЯД**: 1, 2, 3, 4...
3. **НЕ УДАЛЯЕТ** строки (в отличие от GROUP BY)

### Пример 2: ROW_NUMBER() OVER (ORDER BY age) — с сортировкой

```sql
SELECT 
    name,
    age,
    ROW_NUMBER() OVER (ORDER BY age) AS номер_по_возрасту
FROM person;
```

**Результат:**
```
name    | age | номер_по_возрасту
--------|-----|------------------
Анна    | 16  | 1  ← самая младшая
Петя    | 20  | 2
Андрей  | 21  | 3
Денис   | 24  | 4  ← самый старший
```

PostgreSQL:
1. **СОРТИРУЕТ** строки по возрасту (ORDER BY age)
2. Присваивает номера **В ЭТОМ ПОРЯДКЕ**: 1, 2, 3, 4...

### Пример 3: ROW_NUMBER() OVER (PARTITION BY gender) — с разделением

```sql
SELECT 
    name,
    gender,
    ROW_NUMBER() OVER (PARTITION BY gender) AS номер_внутри_пола
FROM person;
```

**Результат:**
```
name    | gender | номер_внутри_пола
--------|--------|------------------
Андрей  | male   | 1  ← первый среди мужчин
Денис   | male   | 2  ← второй среди мужчин
Петя    | male   | 3  ← третий среди мужчин
Анна    | female | 1  ← первая среди женщин
Маша    | female | 2  ← вторая среди женщин
```

PostgreSQL:
1. **РАЗДЕЛЯЕТ** строки на группы (PARTITION BY gender)
2. **В КАЖДОЙ ГРУППЕ** нумерация начинается заново: 1, 2, 3...

## В ТВОЕМ КОДЕ:

```sql
SELECT
    ROW_NUMBER() OVER () AS id,
    person_id,
    menu.pizzeria_id,
    ...
```

### Что происходит:

1. SELECT выбирает строки (группы "человек + пиццерия")
2. ROW_NUMBER() нумерует их: 1, 2, 3, 4...
3. OVER () — пустое окно = "нумеруй ВСЕ строки подряд"
4. AS id — называем этот номер "id"

### Результат:

```
id | person_id | pizzeria_id | discount
---|-----------|-------------|----------
1  | 1         | 5           | 22
2  | 1         | 3           | 30
3  | 2         | 1           | 10.5
4  | 2         | 5           | 22
5  | 3         | 2           | 30
```

Каждая строка получила **уникальный номер** от 1 до N.

## ЗАЧЕМ ЭТО НУЖНО В ТВОЕМ КОДЕ?

Таблица person_discounts требует **id** (PRIMARY KEY). 

Но данные мы берем из person_order через GROUP BY, где **нет** готового id.

ROW_NUMBER() **СОЗДАЕТ** уникальные номера для каждой строки: 1, 2, 3...

Это как **автоматическая нумерация** страниц в тетради.

## СИНТАКСИС OVER ():

```sql
OVER ( [PARTITION BY столбец] [ORDER BY столбец] )
  ↓      ↓                      ↓
"окно"  "разделить на группы"  "отсортировать"
```

- **OVER ()** — пустое = все строки подряд
- **OVER (ORDER BY age)** — сортировать по возрасту
- **OVER (PARTITION BY gender)** — разделить по полу
- **OVER (PARTITION BY gender ORDER BY age)** — разделить по полу И внутри каждой группы сортировать по возрасту

## РАЗНИЦА: GROUP BY vs ОКОННАЯ ФУНКЦИЯ

### GROUP BY (склеивает строки):

```sql
SELECT gender, COUNT(*)
FROM person
GROUP BY gender;
```

Результат:
```
gender | count
-------|------
male   | 3
female | 2
```

**5 человек** → **2 строки** (склеились в группы)

### ОКОННАЯ ФУНКЦИЯ (сохраняет строки):

```sql
SELECT 
    name,
    gender,
    COUNT(*) OVER (PARTITION BY gender) AS людей_этого_пола
FROM person;
```

Результат:
```
name    | gender | людей_этого_пола
--------|--------|------------------
Андрей  | male   | 3
Денис   | male   | 3
Петя    | male   | 3
Анна    | female | 2
Маша    | female | 2
```

**5 человек** → **5 строк** (все остались, но с доп. инфо)

## ИТОГО:

**ROW_NUMBER()** = функция "пронумеруй строки"
**OVER ()** = "для всех строк подряд"
**AS id** = "назови этот номер id"

В твоем коде это создает уникальные id: 1, 2, 3, 4... для каждой вставляемой записи.

Понятно?






















## ПОРЯДОК ВЫПОЛНЕНИЯ (пошагово):

### ШАГ 1: DELETE

```sql
DELETE FROM person_discounts;
```

PostgreSQL **УДАЛЯЕТ** все строки из таблицы person_discounts.

**Аналогия**: Стираешь всё с доски перед новым уроком.

---

### ШАГ 2: INSERT + SELECT (подзапрос)

```sql
INSERT INTO person_discounts (id, person_id, pizzeria_id, discount)
SELECT ...
```

PostgreSQL **НАЧИНАЕТ ВСТАВКУ**, но сначала нужно **ПОЛУЧИТЬ** данные из SELECT.

**Аналогия**: Говоришь "вставь в тетрадь результаты", но сначала нужно эти результаты посчитать.

---

### ШАГ 3: Выполнение SELECT-подзапроса

Здесь **ВАЖНО**: SQL выполняется **НЕ в том порядке, как написан**!

#### Порядок НАПИСАНИЯ (как в коде):

```
1. SELECT
2. FROM
3. JOIN
4. GROUP BY
```

#### Порядок ВЫПОЛНЕНИЯ (как работает PostgreSQL):

```
1. FROM       ← начинаем отсюда!
2. JOIN
3. WHERE      (в твоем коде нет)
4. GROUP BY
5. HAVING     (в твоем коде нет)
6. SELECT     ← только теперь!
7. ORDER BY   (в твоем коде нет)
8. LIMIT      (в твоем коде нет)
```

### ДЕТАЛЬНОЕ ВЫПОЛНЕНИЕ ТВОЕГО SELECT:

#### 3.1. FROM person_order

```sql
FROM person_order
```

PostgreSQL **БЕРЕТ** таблицу person_order (история заказов):

```
id | person_id | menu_id | order_date
---|-----------|---------|------------
1  | 1         | 1       | 2022-01-01
2  | 1         | 2       | 2022-01-02
3  | 2         | 3       | 2022-01-03
...
```

**Аналогия**: Открыл журнал заказов.

---

#### 3.2. INNER JOIN menu

```sql
INNER JOIN menu ON menu.id = person_order.menu_id
```

PostgreSQL **ПРИСОЕДИНЯЕТ** таблицу menu к каждому заказу:

```
person_id | menu_id | pizzeria_id | pizza_name
----------|---------|-------------|------------
1         | 1       | 5           | cheese pizza
1         | 2       | 5           | mushroom pizza
2         | 3       | 1           | pepperoni pizza
...
```

**Аналогия**: К каждому заказу приклеил информацию о блюде и пиццерии.

---

#### 3.3. GROUP BY person_id, menu.pizzeria_id

```sql
GROUP BY person_id, menu.pizzeria_id
```

PostgreSQL **ГРУППИРУЕТ** строки:

**До группировки:**
```
person_id | pizzeria_id
----------|------------
1         | 5          ← заказ 1
1         | 5          ← заказ 2  } объединятся в одну группу
1         | 5          ← заказ 3
2         | 1          ← заказ 4
2         | 1          ← заказ 5  } объединятся в одну группу
2         | 3          ← заказ 6
```

**После группировки:**
```
person_id | pizzeria_id | COUNT(*)
----------|-------------|----------
1         | 5           | 3        ← было 3 заказа
2         | 1           | 2        ← было 2 заказа
2         | 3           | 1        ← был 1 заказ
```

**Аналогия**: Собрал одинаковые карточки в кучки и подсчитал, сколько в каждой кучке.

---

#### 3.4. SELECT (вычисление столбцов)

```sql
SELECT
    ROW_NUMBER() OVER () AS id,
    person_id,
    menu.pizzeria_id,
    CASE WHEN COUNT(*) = 1 THEN 10.5 ... END AS discount
```

PostgreSQL **ВЫЧИСЛЯЕТ** каждый столбец для каждой группы:

**Шаг 3.4.1**: Вычисляет discount (CASE):
```
person_id | pizzeria_id | COUNT(*) | discount
----------|-------------|----------|----------
1         | 5           | 3        | 30       ← 3 заказа → ELSE
2         | 1           | 2        | 22       ← 2 заказа → WHEN COUNT(*) = 2
2         | 3           | 1        | 10.5     ← 1 заказ → WHEN COUNT(*) = 1
```

**Шаг 3.4.2**: Нумерует строки (ROW_NUMBER):
```
id | person_id | pizzeria_id | discount
---|-----------|-------------|----------
1  | 1         | 5           | 30
2  | 2         | 1           | 22
3  | 2         | 3           | 10.5
```

**Аналогия**: Пронумеровал получившиеся кучки карточек.

---

### ШАГ 4: INSERT (вставка данных)

PostgreSQL **ВСТАВЛЯЕТ** результат SELECT в таблицу person_discounts:

```
person_discounts теперь содержит:
id | person_id | pizzeria_id | discount
---|-----------|-------------|----------
1  | 1         | 5           | 30
2  | 2         | 1           | 22
3  | 2         | 3           | 10.5
```

**Аналогия**: Записал результаты в чистую тетрадь.

---

### ШАГ 5: SELECT COUNT (проверка)

```sql
SELECT COUNT(*) > 0 AS check
FROM person_discounts;
```

PostgreSQL **ПРОВЕРЯЕТ**, что в таблице есть строки:

```
check
-----
true   ← в таблице 3 строки (3 > 0)
```

**Аналогия**: Посмотрел в тетрадь — там что-то написано? Да!

---

## ОБЩАЯ СХЕМА ПОРЯДКА:

```
1. DELETE
   └─> Очистить таблицу person_discounts

2. INSERT
   ├─> 3. SELECT-подзапрос:
   │   ├─> 3.1. FROM person_order (взять журнал заказов)
   │   ├─> 3.2. JOIN menu (присоединить меню)
   │   ├─> 3.3. GROUP BY (сгруппировать по человек+пиццерия)
   │   └─> 3.4. SELECT (вычислить столбцы: id, discount)
   │
   └─> 4. Вставить результат в person_discounts

5. SELECT COUNT
   └─> Проверить, что вставка прошла успешно
```

---

## ВАЖНО: Порядок выполнения SELECT

SQL **НЕ выполняется сверху вниз**!

### Как НАПИСАНО:
```sql
SELECT            ← строка 1
FROM              ← строка 2
JOIN              ← строка 3
GROUP BY          ← строка 4
```

### Как ВЫПОЛНЯЕТСЯ:
```
Шаг 1: FROM       ← берем таблицу
Шаг 2: JOIN       ← присоединяем другую таблицу
Шаг 3: GROUP BY   ← группируем
Шаг 4: SELECT     ← только теперь вычисляем столбцы!
```

**Почему так?**

PostgreSQL **сначала** должен понять:
1. Откуда брать данные (FROM)
2. Как их соединить (JOIN)
3. Как их сгруппировать (GROUP BY)

И **только потом** может вычислить:
4. Какие столбцы показать (SELECT)

---

## АНАЛОГИЯ: Приготовление супа

### Написано в рецепте (порядок ЗАПИСИ):
```
1. Подать суп в тарелке        ← SELECT
2. Взять кастрюлю              ← FROM
3. Добавить овощи              ← JOIN
4. Разлить по порциям          ← GROUP BY
```

### Реальный порядок (порядок ВЫПОЛНЕНИЯ):
```
1. Взять кастрюлю              ← FROM (сначала!)
2. Добавить овощи              ← JOIN
3. Разлить по порциям          ← GROUP BY
4. Подать суп в тарелке        ← SELECT (в конце!)
```

Нельзя подать суп, пока не сварил!

---

## ИТОГО:

**Физический порядок (как написано в коде):**
1. DELETE
2. INSERT
3. SELECT + FROM + JOIN + GROUP BY
4. SELECT COUNT

**Логический порядок (как выполняет PostgreSQL):**
1. DELETE (очистка)
2. FROM → JOIN → GROUP BY → SELECT (подготовка данных)
3. INSERT (вставка)
4. SELECT COUNT (проверка)

Понятно?





































## АЛЬТЕРНАТИВНЫЕ СПОСОБЫ РЕШЕНИЯ

### Способ 1: С использованием SERIAL вместо ROW_NUMBER

```sql
-- Временно изменяем тип столбца id на SERIAL (автоинкремент)
ALTER TABLE person_discounts 
    ALTER COLUMN id SET DEFAULT NEXTVAL('seq_person_discounts');

DELETE FROM person_discounts;

-- Вставка БЕЗ указания id - он сгенерируется автоматически
INSERT INTO person_discounts (person_id, pizzeria_id, discount)
SELECT
    person_id,
    menu.pizzeria_id,
    CASE
        WHEN COUNT(*) = 1 THEN 10.5
        WHEN COUNT(*) = 2 THEN 22
        ELSE 30
    END AS discount
FROM person_order 
    INNER JOIN menu ON menu.id = person_order.menu_id
GROUP BY person_id, menu.pizzeria_id;

SELECT COUNT(*) > 0 AS check FROM person_discounts;
```

**Плюсы:**
- Не нужно вручную генерировать id
- Последовательность автоматически увеличивается

**Минусы:**
- Требует предварительной настройки DEFAULT для столбца id

---

### Способ 2: С подзапросом для генерации id

```sql
DELETE FROM person_discounts;

INSERT INTO person_discounts (id, person_id, pizzeria_id, discount)
SELECT
    (SELECT COALESCE(MAX(id), 0) FROM person_discounts) + ROW_NUMBER() OVER () AS id,
    person_id,
    menu.pizzeria_id,
    CASE
        WHEN COUNT(*) = 1 THEN 10.5
        WHEN COUNT(*) = 2 THEN 22
        ELSE 30
    END AS discount
FROM person_order 
    INNER JOIN menu ON menu.id = person_order.menu_id
GROUP BY person_id, menu.pizzeria_id;

SELECT COUNT(*) > 0 AS check FROM person_discounts;
```

**COALESCE(MAX(id), 0)** — находит максимальный существующий id или 0, если таблица пустая
**+ ROW_NUMBER()** — добавляет порядковый номер

**Плюсы:**
- Безопасно при частичной очистке таблицы
- id не конфликтует с существующими

**Минусы:**
- Медленнее из-за подзапроса

---

### Способ 3: С CTE (Common Table Expression) для читаемости

```sql
DELETE FROM person_discounts;

-- WITH создает временный результат (CTE - Common Table Expression)
WITH discount_data AS (
    SELECT
        person_id,
        menu.pizzeria_id,
        CASE
            WHEN COUNT(*) = 1 THEN 10.5
            WHEN COUNT(*) = 2 THEN 22
            ELSE 30
        END AS discount
    FROM person_order 
        INNER JOIN menu ON menu.id = person_order.menu_id
    GROUP BY person_id, menu.pizzeria_id
)
INSERT INTO person_discounts (id, person_id, pizzeria_id, discount)
SELECT
    ROW_NUMBER() OVER () AS id,
    person_id,
    pizzeria_id,
    discount
FROM discount_data;

SELECT COUNT(*) > 0 AS check FROM person_discounts;
```

**WITH ... AS** — создает временную именованную выборку (CTE)
**CTE** (Common Table Expression) — общее табличное выражение, "временная таблица"

**Плюсы:**
- Код читается легче (сначала расчет, потом вставка)
- Можно переиспользовать discount_data в других запросах
- Логика разделена на шаги

**Минусы:**
- Чуть длиннее

---

### Способ 4: С оконной функцией DENSE_RANK (альтернатива ROW_NUMBER)

```sql
DELETE FROM person_discounts;

INSERT INTO person_discounts (id, person_id, pizzeria_id, discount)
SELECT
    DENSE_RANK() OVER (ORDER BY person_id, menu.pizzeria_id) AS id,
    person_id,
    menu.pizzeria_id,
    CASE
        WHEN COUNT(*) = 1 THEN 10.5
        WHEN COUNT(*) = 2 THEN 22
        ELSE 30
    END AS discount
FROM person_order 
    INNER JOIN menu ON menu.id = person_order.menu_id
GROUP BY person_id, menu.pizzeria_id;

SELECT COUNT(*) > 0 AS check FROM person_discounts;
```

**DENSE_RANK()** — оконная функция ранжирования (похожа на ROW_NUMBER)
**ORDER BY person_id, menu.pizzeria_id** — сортирует перед нумерацией

**Разница ROW_NUMBER и DENSE_RANK:**
- **ROW_NUMBER()** — всегда уникальные номера: 1, 2, 3, 4
- **DENSE_RANK()** — может быть одинаковые номера при одинаковых значениях: 1, 2, 2, 3

В нашем случае результат одинаковый, т.к. GROUP BY гарантирует уникальность.

---

### Способ 5: С явным CAST и округлением скидок

```sql
DELETE FROM person_discounts;

INSERT INTO person_discounts (id, person_id, pizzeria_id, discount)
SELECT
    ROW_NUMBER() OVER () AS id,
    person_id,
    menu.pizzeria_id,
    ROUND(
        CASE
            WHEN COUNT(*) = 1 THEN 10.5
            WHEN COUNT(*) = 2 THEN 22.0
            ELSE 30.0
        END::NUMERIC, 
        2
    ) AS discount
FROM person_order 
    INNER JOIN menu ON menu.id = person_order.menu_id
GROUP BY person_id, menu.pizzeria_id;

SELECT COUNT(*) > 0 AS check FROM person_discounts;
```

**ROUND(..., 2)** — округляет до 2 знаков после запятой
**::NUMERIC** — явное преобразование в тип NUMERIC

**Плюсы:**
- Гарантирует точность (не будет 10.50000001)

---

### Способ 6: С подсчетом через подзапрос (без GROUP BY)

```sql
DELETE FROM person_discounts;

INSERT INTO person_discounts (id, person_id, pizzeria_id, discount)
SELECT DISTINCT
    ROW_NUMBER() OVER () AS id,
    po.person_id,
    m.pizzeria_id,
    CASE
        WHEN (
            SELECT COUNT(*) 
            FROM person_order po2 
                INNER JOIN menu m2 ON m2.id = po2.menu_id
            WHERE po2.person_id = po.person_id 
              AND m2.pizzeria_id = m.pizzeria_id
        ) = 1 THEN 10.5
        WHEN (
            SELECT COUNT(*) 
            FROM person_order po2 
                INNER JOIN menu m2 ON m2.id = po2.menu_id
            WHERE po2.person_id = po.person_id 
              AND m2.pizzeria_id = m.pizzeria_id
        ) = 2 THEN 22
        ELSE 30
    END AS discount
FROM person_order po
    INNER JOIN menu m ON m.id = po.menu_id;

SELECT COUNT(*) > 0 AS check FROM person_discounts;
```

**DISTINCT** — убирает дубликаты
**Подзапрос в CASE** — считает количество для каждой пары person_id + pizzeria_id

**Плюсы:**
- Работает без GROUP BY

**Минусы:**
- **ОЧЕНЬ МЕДЛЕННО** (подзапрос выполняется для каждой строки)
- **НЕ РЕКОМЕНДУЕТСЯ** для production

---

### Способ 7: С временной таблицей

```sql
-- Создаем временную таблицу
CREATE TEMP TABLE temp_discounts AS
SELECT
    person_id,
    menu.pizzeria_id,
    CASE
        WHEN COUNT(*) = 1 THEN 10.5
        WHEN COUNT(*) = 2 THEN 22
        ELSE 30
    END AS discount
FROM person_order 
    INNER JOIN menu ON menu.id = person_order.menu_id
GROUP BY person_id, menu.pizzeria_id;

DELETE FROM person_discounts;

-- Вставляем из временной таблицы
INSERT INTO person_discounts (id, person_id, pizzeria_id, discount)
SELECT
    ROW_NUMBER() OVER () AS id,
    person_id,
    pizzeria_id,
    discount
FROM temp_discounts;

-- Удаляем временную таблицу
DROP TABLE temp_discounts;

SELECT COUNT(*) > 0 AS check FROM person_discounts;
```

**CREATE TEMP TABLE** — создает временную таблицу (удаляется автоматически при закрытии сессии)

**Плюсы:**
- Разделение логики на этапы
- Можно проверить промежуточные данные
- Удобно для отладки

**Минусы:**
- Больше кода
- Занимает место в памяти

---

### Способ 8: С использованием GENERATE_SERIES для id

```sql
DELETE FROM person_discounts;

INSERT INTO person_discounts (id, person_id, pizzeria_id, discount)
SELECT
    gs.id,
    dd.person_id,
    dd.pizzeria_id,
    dd.discount
FROM (
    SELECT
        person_id,
        menu.pizzeria_id,
        CASE
            WHEN COUNT(*) = 1 THEN 10.5
            WHEN COUNT(*) = 2 THEN 22
            ELSE 30
        END AS discount,
        ROW_NUMBER() OVER () AS row_num
    FROM person_order 
        INNER JOIN menu ON menu.id = person_order.menu_id
    GROUP BY person_id, menu.pizzeria_id
) dd
    INNER JOIN GENERATE_SERIES(1, (
        SELECT COUNT(*) 
        FROM (
            SELECT person_id, menu.pizzeria_id
            FROM person_order 
                INNER JOIN menu ON menu.id = person_order.menu_id
            GROUP BY person_id, menu.pizzeria_id
        ) sub
    )) AS gs(id) ON gs.id = dd.row_num;

SELECT COUNT(*) > 0 AS check FROM person_discounts;
```

**GENERATE_SERIES(1, N)** — генерирует последовательность чисел от 1 до N

**Минусы:**
- Слишком сложно
- **НЕ РЕКОМЕНДУЕТСЯ**

---

## СРАВНЕНИЕ СПОСОБОВ

| Способ | Сложность | Производительность | Читаемость | Рекомендация |
|--------|-----------|-------------------|------------|--------------|
| **Оригинал (ROW_NUMBER)** | Низкая | Высокая | Хорошая | ✓ Лучший выбор |
| **SERIAL (автоинкремент)** | Низкая | Высокая | Отличная | ✓ Если настроен DEFAULT |
| **С подзапросом MAX(id)** | Средняя | Средняя | Хорошая | Для частичной очистки |
| **CTE (WITH)** | Средняя | Высокая | Отличная | ✓ Для читаемости |
| **DENSE_RANK** | Низкая | Высокая | Хорошая | Альтернатива ROW_NUMBER |
| **С ROUND** | Низкая | Высокая | Хорошая | Для точности |
| **Подзапрос в CASE** | Высокая | **Очень низкая** | Плохая | ❌ НЕ используй |
| **Временная таблица** | Средняя | Высокая | Отличная | Для отладки |
| **GENERATE_SERIES** | Высокая | Низкая | Плохая | ❌ НЕ используй |

---

## РЕКОМЕНДАЦИЯ ДЛЯ ЗАЩИТЫ

**Оригинальный способ (ROW_NUMBER) — лучший выбор**, потому что:
1. Простой и понятный
2. Быстро работает
3. Стандартный подход в SQL

**Если спросят про альтернативы:**
> "Можно использовать CTE (WITH) для лучшей читаемости, или настроить автоинкремент через SERIAL/SEQUENCE, но ROW_NUMBER() — это стандартное решение для массовой генерации уникальных id при вставке."

**Если спросят "почему не подзапрос":**
> "Подзапросы в SELECT выполняются для каждой строки, что очень медленно. GROUP BY + оконные функции выполняются один раз для всего набора данных — это намного эффективнее."