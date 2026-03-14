SELECT 
    pers.name, 
    menu.pizza_name, 
    menu.price, 
    TO_CHAR(
        (menu.price - (menu.price * disc.discount / 100)), 
        'FM999999999999990.99'
    )::NUMERIC AS discount_price,
    pizzeria.name AS pizzeria_name
FROM person_order 
    INNER JOIN menu 
        ON menu.id = person_order.menu_id
    INNER JOIN person AS pers
        ON pers.id = person_order.person_id
    INNER JOIN person_discounts AS disc
        ON pers.id = disc.person_id 
        AND disc.pizzeria_id = menu.pizzeria_id
    INNER JOIN pizzeria 
        ON menu.pizzeria_id = pizzeria.id
ORDER BY 1, 2, 4 DESC;










-- Выбираем данные о заказах с расчетом цены со скидкой
SELECT 
    -- Имя клиента из таблицы person (алиас pers)
    pers.name, 
    
    -- Название пиццы из таблицы menu
    menu.pizza_name, 
    
    -- Оригинальная цена пиццы без скидки
    menu.price, 
    
    -- TO_CHAR - функция преобразования числа в текст с форматированием
    -- Затем обратно в NUMERIC для корректного отображения
    TO_CHAR(
        -- Формула расчета цены со скидкой:
        -- цена - (цена * процент_скидки / 100)
        -- Например: 800 - (800 * 22 / 100) = 800 - 176 = 624
        (menu.price - (menu.price * disc.discount / 100)), 
        
        -- Формат числа для TO_CHAR:
        -- FM (Fill Mode) - режим заполнения, убирает лишние пробелы и незначащие нули
        -- 999999999999990 - позиции для целой части (до 15 цифр)
        -- .99 - позиции для дробной части (2 знака после запятой)
        -- 9 означает "цифра, если она не ноль в начале"
        -- 0 означает "обязательный ноль"
        'FM999999999999990.99'
    )::NUMERIC AS discount_price,
    -- ::NUMERIC - преобразуем текст обратно в числовой тип
    -- AS discount_price - называем результирующий столбец "discount_price"
    
    -- Название пиццерии
    pizzeria.name AS pizzeria_name

-- Начинаем выборку из таблицы person_order (журнал заказов)
FROM person_order 

    -- Присоединяем таблицу menu (меню) по внешнему ключу
    INNER JOIN menu 
        -- Условие связи: id блюда в menu совпадает с menu_id в заказе
        ON menu.id = person_order.menu_id
    
    -- Присоединяем таблицу person (клиенты) с алиасом pers
    INNER JOIN person AS pers
        -- Условие связи: id клиента в person совпадает с person_id в заказе
        ON pers.id = person_order.person_id
    
    -- Присоединяем таблицу person_discounts (персональные скидки) с алиасом disc
    INNER JOIN person_discounts AS disc
        -- Двойное условие связи (AND - оба должны выполняться):
        -- 1. id клиента в person совпадает с person_id в скидках
        ON pers.id = disc.person_id 
        -- 2. id пиццерии в скидках совпадает с pizzeria_id в меню
        -- Это гарантирует, что скидка применяется именно для этой пары клиент-пиццерия
        AND disc.pizzeria_id = menu.pizzeria_id
    
    -- Присоединяем таблицу pizzeria (справочник пиццерий)
    INNER JOIN pizzeria 
        -- Условие связи: id пиццерии в menu совпадает с id в таблице pizzeria
        ON menu.pizzeria_id = pizzeria.id

-- Сортировка результатов:
-- ORDER BY 1, 2, 4 DESC
-- 1 - по первому столбцу (name) по возрастанию (A-Z)
-- 2 - по второму столбцу (pizza_name) по возрастанию (A-Z)
-- 4 - по четвертому столбцу (discount_price) по убыванию (DESC - от большего к меньшему)
-- Если имена и пиццы одинаковые, сортируем по цене со скидкой от большей к меньшей
ORDER BY 1, 2, 4 DESC;
```

---

## ОБЪЯСНЕНИЕ TO_CHAR И FM

### TO_CHAR(число, формат)
**TO_CHAR** — преобразует число в текст с указанным форматом.

**Формат 'FM999999999999990.99':**
- **FM** (Fill Mode) — убирает лишние пробелы слева и незначащие нули справа
- **999999999999990** — шаблон для целой части (15 позиций)
- **.99** — шаблон для дробной части (2 позиции)

**Символы формата:**
- **9** — опциональная цифра (не показывается, если ноль в начале)
- **0** — обязательная цифра (показывается всегда)

**Примеры:**
```sql
TO_CHAR(624, 'FM999999999999990.99')      → '624.00'
TO_CHAR(805.5, 'FM999999999999990.99')    → '805.50'
TO_CHAR(10.5, 'FM999999999999990.99')     → '10.50'
```

**Затем ::NUMERIC** преобразует текст обратно в число, убирая лишние нули:
```sql
'624.00'::NUMERIC  → 624
'805.50'::NUMERIC  → 805.5
'10.50'::NUMERIC   → 10.5
```

---

## АЛЬТЕРНАТИВНЫЕ СПОСОБЫ

### Способ 1: TRIM (убрать нули вручную)

```sql
SELECT 
    pers.name, 
    menu.pizza_name, 
    menu.price, 
    TRIM(TRAILING '0' FROM 
        TRIM(TRAILING '.' FROM 
            (menu.price - (menu.price * disc.discount / 100))::TEXT
        )
    )::NUMERIC AS discount_price,
    pizzeria.name AS pizzeria_name
FROM person_order 
    INNER JOIN menu ON menu.id = person_order.menu_id
    INNER JOIN person AS pers ON pers.id = person_order.person_id
    INNER JOIN person_discounts AS disc 
        ON pers.id = disc.person_id AND disc.pizzeria_id = menu.pizzeria_id
    INNER JOIN pizzeria ON menu.pizzeria_id = pizzeria.id
ORDER BY 1, 2, 4 DESC;
```

**Как работает:**
1. `::TEXT` — число в текст: `624.0000000`
2. `TRIM(TRAILING '.')` — убираем точку справа (если будет)
3. `TRIM(TRAILING '0')` — убираем нули справа: `624.0000000` → `624`
4. `::NUMERIC` — текст обратно в число

**TRIM** — функция обрезки символов
**TRAILING** — справа (есть еще LEADING — слева, BOTH — с обеих сторон)

---

### Способ 2: ROUND + CAST (округление и приведение типа)

```sql
SELECT 
    pers.name, 
    menu.pizza_name, 
    menu.price, 
    ROUND(
        CAST(menu.price - (menu.price * disc.discount / 100) AS NUMERIC), 
        2
    ) AS discount_price,
    pizzeria.name AS pizzeria_name
FROM person_order 
    INNER JOIN menu ON menu.id = person_order.menu_id
    INNER JOIN person AS pers ON pers.id = person_order.person_id
    INNER JOIN person_discounts AS disc 
        ON pers.id = disc.person_id AND disc.pizzeria_id = menu.pizzeria_id
    INNER JOIN pizzeria ON menu.pizzeria_id = pizzeria.id
ORDER BY 1, 2, 4 DESC;
```

**CAST(... AS NUMERIC)** — явное преобразование типа (аналог ::NUMERIC, но более читаемо)
**ROUND(..., 2)** — округление до 2 знаков после запятой

---

### Способ 3: ::REAL (числа с плавающей точкой)

```sql
SELECT 
    pers.name, 
    menu.pizza_name, 
    menu.price, 
    (menu.price - (menu.price * disc.discount / 100))::REAL AS discount_price,
    pizzeria.name AS pizzeria_name
FROM person_order 
    INNER JOIN menu ON menu.id = person_order.menu_id
    INNER JOIN person AS pers ON pers.id = person_order.person_id
    INNER JOIN person_discounts AS disc 
        ON pers.id = disc.person_id AND disc.pizzeria_id = menu.pizzeria_id
    INNER JOIN pizzeria ON menu.pizzeria_id = pizzeria.id
ORDER BY 1, 2, 4 DESC;
```

**::REAL** — тип данных с плавающей точкой (4 байта, меньше точности чем NUMERIC)
**Плюс:** автоматически показывает без лишних нулей
**Минус:** может быть погрешность в вычислениях (624.00000001 вместо 624)

---

### Способ 4: COALESCE + NULLIF (экзотический)

```sql
SELECT 
    pers.name, 
    menu.pizza_name, 
    menu.price, 
    COALESCE(
        NULLIF(ROUND((menu.price - (menu.price * disc.discount / 100)), 2), 
               TRUNC(menu.price - (menu.price * disc.discount / 100))),
        TRUNC(menu.price - (menu.price * disc.discount / 100))
    ) AS discount_price,
    pizzeria.name AS pizzeria_name
FROM person_order 
    INNER JOIN menu ON menu.id = person_order.menu_id
    INNER JOIN person AS pers ON pers.id = person_order.person_id
    INNER JOIN person_discounts AS disc 
        ON pers.id = disc.person_id AND disc.pizzeria_id = menu.pizzeria_id
    INNER JOIN pizzeria ON menu.pizzeria_id = pizzeria.id
ORDER BY 1, 2, 4 DESC;
```

Слишком сложно, **НЕ РЕКОМЕНДУЮ**.

---

## СРАВНЕНИЕ СПОСОБОВ

| Способ | Сложность | Точность | Скорость | Рекомендация |
|--------|-----------|----------|----------|--------------|
| **TO_CHAR + FM** | Средняя | Высокая | Средняя | ✓ Хороший выбор |
| **TRIM** | Высокая | Высокая | Медленная | Надежно, но сложно |
| **ROUND + CAST** | Низкая | Высокая | Быстрая | ✓ Простой выбор |
| **::REAL** | Низкая | Низкая | Быстрая | Может быть погрешность |

---

## РЕКОМЕНДАЦИЯ ДЛЯ ЗАЩИТЫ

**Используй TO_CHAR с FM** — это стандартный способ форматирования чисел в PostgreSQL.

Если спросят "а почему не просто ::NUMERIC?":
> "::NUMERIC оставляет все знаки после запятой, которые были при вычислении. TO_CHAR с форматом FM позволяет точно контролировать количество знаков и убрать незначащие нули."

Если спросят "что такое FM?":
> "Fill Mode — режим заполнения в PostgreSQL, который убирает лишние пробелы и незначащие нули при форматировании чисел."