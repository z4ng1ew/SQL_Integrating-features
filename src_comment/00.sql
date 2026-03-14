DROP TABLE IF EXISTS person_discounts;

CREATE TABLE person_discounts (
    id BIGINT PRIMARY KEY,
    person_id BIGINT,
    pizzeria_id BIGINT,
    discount NUMERIC,
    CONSTRAINT fk_person_discounts_person_id 
        FOREIGN KEY (person_id) REFERENCES person(id),
    CONSTRAINT fk_person_discounts_pizzeria_id 
        FOREIGN KEY (pizzeria_id) REFERENCES pizzeria(id)
);

SELECT COUNT(*) = 1 AS check
FROM pg_tables
WHERE tablename = 'person_discounts';


















-- Удаляем таблицу person_discounts, если она уже существует
-- IF EXISTS предотвращает ошибку, если таблицы нет
-- Это обеспечивает идемпотентность (возможность запускать скрипт многократно)
DROP TABLE IF EXISTS person_discounts;

-- Создаем новую таблицу person_discounts для хранения персональных скидок
CREATE TABLE person_discounts (
    
    -- Столбец id - первичный ключ (Primary Key)
    -- BIGINT - целое число большого размера (8 байт, от -9 квинтиллионов до +9 квинтиллионов)
    -- PRIMARY KEY - уникальный идентификатор каждой записи, не может быть NULL, автоматически создает индекс
    id BIGINT PRIMARY KEY,
    
    -- Столбец person_id - ссылка на клиента
    -- BIGINT - такой же тип, как id в таблице person (для совместимости Foreign Key)
    -- Хранит идентификатор человека, который получает скидку
    person_id BIGINT,
    
    -- Столбец pizzeria_id - ссылка на пиццерию
    -- BIGINT - такой же тип, как id в таблице pizzeria
    -- Хранит идентификатор пиццерии, которая предоставляет скидку
    pizzeria_id BIGINT,
    
    -- Столбец discount - процент скидки
    -- NUMERIC - числовой тип с произвольной точностью (может хранить дробные числа: 10.5, 22.75)
    -- Используется для точных вычислений (в отличие от FLOAT, где могут быть погрешности)
    discount NUMERIC,
    
    -- Ограничение внешнего ключа для person_id
    -- CONSTRAINT - именованное ограничение (можно потом найти по имени в системных таблицах)
    -- fk_person_discounts_person_id - явное имя по шаблону fk_{таблица}_{столбец}
    -- FOREIGN KEY (person_id) - объявляем, что person_id это внешний ключ
    -- REFERENCES person(id) - он ссылается на столбец id таблицы person
    -- Это гарантирует, что в person_discounts нельзя добавить несуществующего клиента
    CONSTRAINT fk_person_discounts_person_id 
        FOREIGN KEY (person_id) REFERENCES person(id),
    
    -- Ограничение внешнего ключа для pizzeria_id
    -- Аналогично предыдущему, но для таблицы pizzeria
    -- Гарантирует ссылочную целостность - нельзя создать скидку для несуществующей пиццерии
    CONSTRAINT fk_person_discounts_pizzeria_id 
        FOREIGN KEY (pizzeria_id) REFERENCES pizzeria(id)
);

-- Проверка успешности создания таблицы
-- SELECT - запрос на выборку данных
-- COUNT(*) - подсчет количества строк
-- = 1 - проверка, что таблица найдена ровно один раз
-- AS check - псевдоним для результата (столбец будет называться "check")
SELECT COUNT(*) = 1 AS check
-- FROM pg_tables - системная таблица PostgreSQL, содержащая информацию обо всех таблицах в БД
FROM pg_tables
-- WHERE tablename = 'person_discounts' - фильтр: ищем только нашу таблицу
-- Результат должен быть "true", что подтверждает успешное создание таблицы
WHERE tablename = 'person_discounts';


## Краткий пересказ для устной защиты:

**Строка 1-2**: Удаляю старую таблицу, если она есть, чтобы скрипт можно было запускать повторно.

**Строка 4**: Создаю таблицу person_discounts - она будет хранить связь "клиент-пиццерия-скидка".

**Строка 6-7**: id - первичный ключ типа BIGINT, уникальный номер каждой скидки.

**Строка 9-10**: person_id - внешний ключ на таблицу person, показывает, кто получает скидку.

**Строка 12-13**: pizzeria_id - внешний ключ на таблицу pizzeria, показывает, где действует скидка.

**Строка 15-16**: discount - процент скидки, тип NUMERIC для точного хранения дробных чисел.

**Строки 18-21**: Создаю именованный Foreign Key constraint для person_id - это гарантирует, что в таблице не будет ссылок на несуществующих клиентов.

**Строки 23-25**: Аналогичный Foreign Key для pizzeria_id.

**Строки 28-32**: Проверочный запрос - убеждаюсь, что таблица успешно создана, обращаясь к системному каталогу pg_tables.





































Объясню простыми словами, что нужно сделать.

## Бизнес-задача

У тебя есть пиццерии и клиенты. Пиццерии хотят давать **персональные скидки** постоянным клиентам. Например:
- Андрей часто заказывает в "Dominos" → получает скидку 22%
- Денис часто заказывает в "Best Pizza" → получает скидку 30%
- Анна впервые заказала в "Pizza Hut" → получает скидку 10.5%

Скидка **индивидуальная** для каждой пары "клиент + пиццерия".

## Что нужно создать

Таблицу `person_discounts`, которая будет хранить информацию:
- **Кто** получает скидку (клиент)
- **Где** получает скидку (в какой пиццерии)
- **Сколько процентов** скидка

## Структура таблицы (столбцы)

### 1. Столбец `id` (Primary Key)

**Primary Key** (первичный ключ) — уникальный номер каждой записи, как номер паспорта у человека.

```
id = 1  → "Андрей получает 22% скидки в Dominos"
id = 2  → "Денис получает 30% скидки в Best Pizza"
```

**Тип данных**: посмотри в существующих таблицах (person, pizzeria, menu), какой тип у столбца `id` — используй такой же (скорее всего BIGINT).

### 2. Столбец `person_id` (Foreign Key)

**Foreign Key** (внешний ключ) — это ссылка на другую таблицу.

`person_id` — это **номер клиента** из таблицы `person`. Например:
- person_id = 1 означает "Андрей" (если в таблице person у Андрея id=1)
- person_id = 2 означает "Анна"

**Тип данных**: такой же, как у столбца `id` в таблице `person`.

### 3. Столбец `pizzeria_id` (Foreign Key)

`pizzeria_id` — это **номер пиццерии** из таблицы `pizzeria`. Например:
- pizzeria_id = 5 означает "Dominos"
- pizzeria_id = 3 означает "Best Pizza"

**Тип данных**: такой же, как у столбца `id` в таблице `pizzeria`.

### 4. Столбец `discount`

Это сам **процент скидки**. Может быть:
- Целым числом: 10, 22, 30
- Дробным числом: 10.5, 22.75, 15.25

**Тип данных**: NUMERIC (умеет хранить дроби).

## Ограничения (constraints)

### Foreign Key с именем

Когда создаешь связь между таблицами, нужно дать ей понятное имя по шаблону:
```
fk_{название_нашей_таблицы}_{название_столбца}
```

Примеры:
- Для person_id: `fk_person_discounts_person_id`
- Для pizzeria_id: `fk_person_discounts_pizzeria_id`

Это нужно, чтобы потом можно было легко найти это ограничение в базе данных.

## Аналогия из жизни

Представь **систему скидочных карт**:

| Карта № (id) | Владелец (person_id) | Магазин (pizzeria_id) | Скидка (discount) |
|--------------|----------------------|------------------------|-------------------|
| 1            | Андрей               | Dominos                | 22%               |
| 2            | Денис                | Best Pizza             | 30%               |
| 3            | Анна                 | Pizza Hut              | 10.5%             |

Каждая строка = одна скидочная карта для конкретного человека в конкретной пиццерии.

## Итоговый SQL (который уже готов)

```sql
CREATE TABLE person_discounts (
    id BIGINT PRIMARY KEY,                    -- уникальный номер записи
    person_id BIGINT,                         -- ссылка на клиента
    pizzeria_id BIGINT,                       -- ссылка на пиццерию
    discount NUMERIC,                         -- процент скидки (может быть дробным)
    CONSTRAINT fk_person_discounts_person_id  -- имя ограничения
        FOREIGN KEY (person_id) REFERENCES person(id),  -- связь с таблицей person
    CONSTRAINT fk_person_discounts_pizzeria_id 
        FOREIGN KEY (pizzeria_id) REFERENCES pizzeria(id)
);
```

Понятнее стало?













FOREIGN KEY = Охранник на входе, который физически не пропустит человека без паспорта



























Хорошо, начну с нуля, совсем просто.

## Почему нельзя использовать JOIN и VIEW?

Потому что **JOIN и VIEW** — это для **ЧТЕНИЯ** данных, а **FOREIGN KEY** — это **ЗАЩИТА** от дурака.

### Аналогия: Паспортный контроль

**JOIN** = Ты просто **смотришь** списки и **сравниваешь** их глазами
**FOREIGN KEY** = Охранник на входе, который **физически не пропустит** человека без паспорта

### Пример:

**Таблица person** (список студентов):
```
id | имя
1  | Андрей
2  | Денис
```

**Таблица person_discounts** (кто получает скидки):
```
person_id | скидка
1         | 10%
2         | 20%
```

### С JOIN (просто смотришь):

```sql
SELECT * FROM person_discounts
JOIN person ON person.id = person_discounts.person_id;
```

Это как взять две тетради и **глазами** посмотреть, кто кому соответствует. Но **ничего не запрещает**!

Я могу взять и написать:
```sql
INSERT INTO person_discounts (person_id, скидка) VALUES (999, 50%);
```

PostgreSQL **РАЗРЕШИТ** это, потому что JOIN — это не правило, это просто способ смотреть данные.

Теперь в базе:
```
person_id | скидка
1         | 10%
2         | 20%
999       | 50%   <--- КТО ЭТО???? Студента 999 НЕТ!
```

### С FOREIGN KEY (охранник):

```sql
CREATE TABLE person_discounts (
    person_id BIGINT,
    CONSTRAINT fk_person_discounts_person_id 
        FOREIGN KEY (person_id) REFERENCES person(id)
);
```

Теперь пытаюсь вставить:
```sql
INSERT INTO person_discounts (person_id, скидка) VALUES (999, 50%);
```

PostgreSQL **БЛОКИРУЕТ**:
```
ОШИБКА: нарушение ограничения fk_person_discounts_person_id
Студента с id=999 не существует в таблице person!
```

**JOIN** = инструмент для чтения
**FOREIGN KEY** = замок на двери

## Из какой таблицы столбец person_id?

**Из ЭТОЙ таблицы!** Из той, которую мы сейчас создаем — `person_discounts`.

```sql
CREATE TABLE person_discounts (  <--- ВОТ ЭТА ТАБЛИЦА!
    id BIGINT PRIMARY KEY,
    person_id BIGINT,            <--- ЭТОТ СТОЛБЕЦ ЗДЕСЬ, В person_discounts
    pizzeria_id BIGINT,
    discount NUMERIC,
    CONSTRAINT fk_person_discounts_person_id 
        FOREIGN KEY (person_id)  <--- берем столбец person_id ИЗ ЭТОЙ ТАБЛИЦЫ
        REFERENCES person(id)    <--- он должен ссылаться на столбец id в ДРУГОЙ таблице person
);
```

### Визуально:

```
ТАБЛИЦА person_discounts          ТАБЛИЦА person
┌────────────────────┐            ┌──────────┐
│ id                 │            │ id       │ <--- СЮДА СМОТРИМ
│ person_id ────────────────────> │ name     │
│ pizzeria_id        │            │ age      │
│ discount           │            └──────────┘
└────────────────────┘
```

**person_id** живет в **person_discounts**, но **ССЫЛАЕТСЯ** на **id** в таблице **person**.

## Зачем FOREIGN KEY — на примере из жизни

### Ситуация: Библиотека

**Таблица "Читатели"** (person):
```
id | имя
1  | Вася
2  | Петя
```

**Таблица "Кто взял книги"** (person_discounts):
```
читатель_id | книга
1           | Война и мир
2           | Мастер и Маргарита
```

### БЕЗ FOREIGN KEY (хаос):

Библиотекарь случайно записал:
```
читатель_id | книга
1           | Война и мир
2           | Мастер и Маргарита
999         | Анна Каренина  <--- КТО ВЗЯЛ??? Читателя 999 НЕТ!
```

Теперь:
- Книга пропала
- Не понятно, кому звонить
- База данных врет
- Нельзя вернуть книгу

### С FOREIGN KEY (порядок):

Библиотекарь пытается записать:
```
читатель_id | книга
999         | Анна Каренина
```

Компьютер **БЛОКИРУЕТ**:
```
ОШИБКА! Читателя с номером 999 не существует!
Сначала зарегистрируй его в таблице "Читатели"!
```

Библиотекарь:
1. Идет к читателю
2. Записывает его в таблицу "Читатели" (id=3, имя=Коля)
3. ТЕПЕРЬ может записать в "Кто взял книги": читатель_id=3, книга=Анна Каренина

**FOREIGN KEY = правило, которое не дает записать мусор в базу**

## Еще проще: Школьный дневник

**Журнал класса** (person):
```
№  | ученик
1  | Вася
2  | Петя
3  | Маша
```

**Дневник Васи** (person_discounts):
```
ученик_№ | оценка | предмет
1        | 5      | Математика
1        | 4      | Русский
```

### БЕЗ FOREIGN KEY:

Учитель случайно записал в дневник:
```
ученик_№ | оценка | предмет
999      | 3      | Физика  <--- ЧЕЙ ЭТО ДНЕВНИК?? Ученика 999 НЕТ В КЛАССЕ!
```

### С FOREIGN KEY:

Система не даст записать оценку для несуществующего ученика.

## Короткий ответ

**JOIN** = способ ПОСМОТРЕТЬ связанные данные (не защищает от ошибок)
**FOREIGN KEY** = ПРАВИЛО, которое запрещает вставлять мусор (защищает от ошибок)

**person_id** = столбец в таблице **person_discounts** (та, которую создаем)
**REFERENCES person(id)** = этот столбец должен брать значения только из столбца **id** таблицы **person**

**Зачем FOREIGN KEY?** = Чтобы в базе не было записей типа "Скидка для студента №999", когда студента №999 вообще не существует.

Понятно теперь?


































КАКУКУЮ РОЛЬ FOREIGN KEY В CONSTRAINT И В REFERENCES ?


МОЖНО ЛИ ПИСАТЬ REFERENCES И CONSTRAINT  ПО ОТДЕЛЬНОСТИ ?



Короткий ответ
JOIN = способ ПОСМОТРЕТЬ связанные данные (не защищает от ошибок) FOREIGN KEY = ПРАВИЛО, которое запрещает вставлять мусор (защищает от ошибок)
person_id = столбец в таблице person_discounts (та, которую создаем) REFERENCES person(id) = этот столбец должен брать значения только из столбца id таблицы person
Зачем FOREIGN KEY? = Чтобы в базе не было записей типа "Скидка для студента No999", когда студента No999 вообще не существует.


* РАЗВЕ КОМАНДА КОТОРАЯ ЗАПРЕЩАЕТ ЭТО НЕ CONSTRAINT ? ПРИ ЧЁМ ТУТ  FOREIGN KEY ???
Я ТАК ПОНИМАЮ ЧТО FOREIGN KEY - СТЕРМИТЬСЯ НАХОДИТЬ СООТВЕТСТВИЕ МЕЖДУ РАНЫМИ ТАБЛИЦАМИ ЧТО БЫ НЕ БЫЛО НЕСВЯЗАННЫХ ДАННЫХ, ЧТО БЫ ПРИР ВВОДЕ ДАННЫХ В ОДНУ ТАБЛИЦУ ТО ОНИ ОДНОВРЕМЕНННО ДОЛЖНЫ БЫТЬ И ВВЕДЕНЫ И В ДРУГУЮ - ДЛЯ СООТВЕСТВИЯ. А ВОТ ЗА НЕПОСРЕДСТВЕННОЕ ОГРАНИЧЕНИЕ У НАС ОТВЕЧАЕТ CONSTRAINT И ОН ЖЕ ДАЁТ НАМ ВОЗМОЖНОСТЬ ДАВАТЬ НАЗВАНИЯ , А REFERENCES ДАЁТ ВОЗМОДЖЖНОСТЬ НЕПОСРЕДСТВЕННО СВЯЗАТЬ ДАННЫЕ ИЗ РАЗНЫХ ДАВЛЦ И СДЕЛАТЬ ВЗАИМОСВЯЗЬ, ВЗАИМОЗАВИСИМОСТЬ В ТО ВРЕМЯ КАК FOREIGN KEY - ТОДЛЬКО КАК ОХРАННИК СЛЕДИТ ТОЛЬКО ЗА ТЕМ ЧТО БЫ ТАБЛИЦЫ БЫЛИ ИДЕНТИЧНЫЫ ПО ID
ТОЕСТЬ АЙДИ ИЗ ТАБЛИЦЫ ПЕРСОНН СВЯЗЫВАЕТСЯ С АЙДИ НОВОЙ ТАБЛИЦЫ ПЕРСОН_ДИСКАУНТ АЙДИ







## ТЫ ПОЧТИ ПРАВ! Но давай разложу по полочкам:

## FOREIGN KEY - это НЕ охранник, это НАЗВАНИЕ ТИПА ПРАВИЛА!

Как в армии есть звания: **рядовой, сержант, лейтенант** — это НАЗВАНИЯ рангов.

Так и в PostgreSQL есть **типы правил**:
- **PRIMARY KEY** (тип правила "главный ключ")
- **FOREIGN KEY** (тип правила "внешний ключ") 
- **CHECK** (тип правила "проверка условия")
- **UNIQUE** (тип правила "уникальность")
- **NOT NULL** (тип правила "не пустое")

## Разбор по ролям:

### 1. CONSTRAINT = "Я даю имя правилу"

Просто слово, которое позволяет придумать название.

### 2. FOREIGN KEY = "Тип правила - внешний ключ"

Это не охранник! Это **НАЗВАНИЕ ТИПА** правила, как "паспорт" - это тип документа.

### 3. REFERENCES = "На кого ссылаться"

Это часть синтаксиса FOREIGN KEY. Без REFERENCES не работает.

## Правильная формула:

```
CONSTRAINT [имя] FOREIGN KEY (столбец) REFERENCES другая_таблица(столбец)
    ↓         ↓        ↓          ↓              ↓
  "создаю   "моё   "тип    "какой столбец   "куда он смотрит"
   правило  название" правила"  проверяю"
   с именем"
```

## Можно ли писать REFERENCES и CONSTRAINT по отдельности?

### ДА! Есть ДВА способа:

### Способ 1: БЕЗ CONSTRAINT (короткий)

```sql
CREATE TABLE person_discounts (
    person_id BIGINT REFERENCES person(id)
                      ↑
                      Здесь FOREIGN KEY подразумевается автоматически!
);
```

Здесь:
- CONSTRAINT нет (имя создаст PostgreSQL сам)
- FOREIGN KEY нет (он подразумевается, когда пишешь REFERENCES)
- REFERENCES есть

**Читается**: "person_id ссылается на person(id)"

### Способ 2: С CONSTRAINT (полный)

```sql
CREATE TABLE person_discounts (
    person_id BIGINT,
    CONSTRAINT fk_person_discounts_person_id 
        FOREIGN KEY (person_id) REFERENCES person(id)
);
```

Здесь:
- CONSTRAINT есть (даем имя)
- FOREIGN KEY есть (явно указываем тип правила)
- REFERENCES есть (на кого ссылаться)

**Читается**: "Создай правило с именем fk_person_discounts_person_id, типа FOREIGN KEY, столбец person_id ссылается на person(id)"

## РАЗВЕ CONSTRAINT НЕ ЗАПРЕЩАЕТ?

**НЕТ!** CONSTRAINT сам по себе **НИЧЕГО НЕ ЗАПРЕЩАЕТ**!

CONSTRAINT - это просто **слово "правило с именем"**.

Запрещает **FOREIGN KEY**!

### Аналогия: Закон

```
CONSTRAINT                = "Статья 228"
FOREIGN KEY               = "Хранение наркотиков"
REFERENCES person(id)     = "запрещено по УК РФ"
```

**CONSTRAINT** = просто номер статьи (имя)
**FOREIGN KEY** = сам закон (тип правила)
**REFERENCES** = к чему применяется закон

## Кто за что отвечает?

| Элемент | Роль | Аналогия |
|---------|------|----------|
| **CONSTRAINT** | Дает имя | "Назовем это правило 'Вася'" |
| **FOREIGN KEY** | Определяет ТИП правила | "Это правило типа 'внешний ключ'" |
| **REFERENCES** | Указывает куда смотреть | "Смотри в таблицу person, столбец id" |

## Твоя мысль про роли - ИСПРАВЛЮ:

### Ты написал:
> FOREIGN KEY стремится находить соответствие

**НЕТ!** FOREIGN KEY - это просто **ТИП ПРАВИЛА**. Он ничего не ищет, он просто **категория**.

### Ты написал:
> CONSTRAINT дает возможность давать названия

**ДА!** Правильно!

### Ты написал:
> REFERENCES дает возможность связать данные

**ДА!** Правильно! REFERENCES - это часть синтаксиса, которая говорит "куда смотреть".

### Ты написал:
> FOREIGN KEY следит только за тем, чтобы таблицы были идентичны по ID

**НЕТ!** Не совсем. FOREIGN KEY **+ REFERENCES вместе** создают правило: "значения в этом столбце должны существовать в той таблице".

## Правильная схема:

```sql
CONSTRAINT fk_person_discounts_person_id 
    FOREIGN KEY (person_id) REFERENCES person(id)
```

**По-русски:**

1. **CONSTRAINT** = "Создаю правило"
2. **fk_person_discounts_person_id** = "Называю его так"
3. **FOREIGN KEY** = "Тип правила: внешний ключ"
4. **(person_id)** = "Проверяй столбец person_id"
5. **REFERENCES** = "Он должен ссылаться на"
6. **person(id)** = "Таблицу person, столбец id"

## Кто РЕАЛЬНО запрещает вставлять мусор?

**Вся конструкция FOREIGN KEY + REFERENCES вместе!**

Без REFERENCES слово FOREIGN KEY бессмысленно, потому что непонятно "на что ссылаться".

## Итого:

- **CONSTRAINT** = даёт имя
- **FOREIGN KEY** = тип правила (как "паспорт" - тип документа)
- **REFERENCES** = куда смотреть
- **Вместе FOREIGN KEY + REFERENCES** = создают правило "столбец должен ссылаться на другую таблицу"

**CONSTRAINT сам по себе не запрещает!** Он просто слово "правило называется так-то".

Понятно?
















```sql

CONSTRAINT fk_person_discounts_pizzeria_id 

        FOREIGN KEY (pizzeria_id) REFERENCES pizzeria(id)

```



(CONSTRAINT ) ТУТ ГОВОРИТСЯ СОЗДАЙ ОГРАНИЧЕНИЕ С НАЗВАНИЕМ fk_person_discounts_pizzeria_id   - НАЗВАНИЕ ДАНО ПО ФОРМУЛЕ - fk_{table_name - ПОДРАЗУМЕВАЕТСЯ ИМЯ ТАБЛИЦЫ КОТОРАЯ СОЗДАЕТСЯ person_discounts}_{column_name - КОЛОНКА ТАБЛИЦЫ person_discounts А ИМЕННО pizzeria }.



ТИП ОГРАНИЧЕНИЯ ПО FOREIGN KEY ТО ЕСТЬ ЗНАЧЕНИЯ ИЗ НОВОЙ ТАБЛИЦЫ ( ТОЕСТЬ КОЛОНКА ИЗ НОВО ТАБЛИЦЫ - pizzeria_id) ДОЛЖНЫ СУЩЕСТВОВАТЬ В ТАБЛИЦЕ СТАРОЙ - А ИМЕННО pizzeria, ПО КОЛОНКЕ ID. ЧЕСТНО ГОВОРЯ КАКОЙ ТО СТРАННЫЙ СИНТАКСИС  С ЛЕВА ОТ REFERENCES У НАС    НАВАНИЕ КОЛОНКИ В СКОБКАХ НО НЕТ НАЗВАНИЯ ТАБЛИЦЫ РЯДОМ С ЭТИМИ СКОБКАМИ А С ПРАВА ЕСТЬ И НАЗВАНИЕ ТАБЛИЦЫ И НАВЗАНИЕ КОЛОНКИ В СКОБКАХ  - ОБЯСНИ МНЕ ЭТОТ МОМЕНТ !??!?!?!?!?!?



REFERENCES - ДАЁТ ВОЗМОЖНОСТЬ СВЗЯТЬ ДАННЫЕ КОНКРЕТНО ИЗ КОЛОНКИ pizzeria_id ИЗ НОВОЙ ТАБЛИЦЫ  person_discounts  С ДАННЫМИ ИЗ  КОЛОНКИ id ТАБЛИЦЫ pizzeria


- тоесть всё это защита от дурака, что бы защитить данные из одной таблицы от односторонних измнений без внесения изменений во вторую таблицу ??


Правильно ли я всё понял ?






## ДА! ТЫ ПОЧТИ ВСЁ ПРАВИЛЬНО ПОНЯЛ!

Разберу по пунктам:

### 1. CONSTRAINT - ДА, ВЕРНО! ✓

```
CONSTRAINT fk_person_discounts_pizzeria_id
```

"Создаю ограничение с названием **fk_person_discounts_pizzeria_id**"

Формула названия: **fk_{таблица_которую_создаём}_{столбец_в_этой_таблице}**

### 2. FOREIGN KEY - ДА, ВЕРНО! ✓

Тип ограничения: **внешний ключ**

Значения из столбца **pizzeria_id** (новая таблица) ДОЛЖНЫ существовать в таблице **pizzeria**, в столбце **id**.

### 3. СТРАННЫЙ СИНТАКСИС - ОБЪЯСНЯЮ!

```sql
FOREIGN KEY (pizzeria_id) REFERENCES pizzeria(id)
            ↑                        ↑
        СЛЕВА: только столбец    СПРАВА: таблица(столбец)
```

## ПОЧЕМУ СЛЕВА НЕТ НАЗВАНИЯ ТАБЛИЦЫ?

Потому что мы **ВНУТРИ** создания таблицы `person_discounts`!

```sql
CREATE TABLE person_discounts (  <--- МЫ ЗДЕСЬ, ВНУТРИ!
    ...
    CONSTRAINT fk_person_discounts_pizzeria_id 
        FOREIGN KEY (pizzeria_id)  <--- СТОЛБЕЦ ИЗ ЭТОЙ ТАБЛИЦЫ (person_discounts)
        REFERENCES pizzeria(id)     <--- ТАБЛИЦА И СТОЛБЕЦ СНАРУЖИ
);
```

PostgreSQL **УЖЕ ЗНАЕТ**, что мы говорим про таблицу `person_discounts`, потому что мы её сейчас создаём!

### Аналогия: Разговор

Представь, ты стоишь **в своей комнате** и говоришь другу:

**СЛЕВА (без таблицы):**
- "Мой телефон" - понятно, что телефон **в ЭТОЙ комнате**
- "Моя книга" - понятно, что книга **в ЭТОЙ комнате**

**СПРАВА (с таблицей):**
- "Телефон **Васи**" - нужно уточнить, ЧЕЙ, потому что не твой
- "Книга **из библиотеки**" - нужно уточнить, ОТКУДА

### В SQL:

**СЛЕВА:**
```sql
FOREIGN KEY (pizzeria_id)
            ↑
     Столбец ИЗ ЭТОЙ ТАБЛИЦЫ (person_discounts)
     Название таблицы НЕ НУЖНО - мы УЖЕ ВНУТРИ неё!
```

**СПРАВА:**
```sql
REFERENCES pizzeria(id)
           ↑       ↑
       таблица  столбец
       
     ДРУГАЯ таблица, СНАРУЖИ
     Название таблицы ОБЯЗАТЕЛЬНО - PostgreSQL не знает, КАКУЮ таблицу ты имеешь в виду!
```

## Полная схема:

```sql
CREATE TABLE person_discounts (          -- СОЗДАЁМ ЭТУ ТАБЛИЦУ
    pizzeria_id BIGINT,                  -- ЭТОТ СТОЛБЕЦ ЗДЕСЬ ↓
    CONSTRAINT fk_person_discounts_pizzeria_id 
        FOREIGN KEY (pizzeria_id)        -- ← берём ОТСЮДА (из person_discounts)
        REFERENCES pizzeria(id)          -- → должен существовать ТАМ (в pizzeria)
);
```

## Визуально:

```
ТАБЛИЦА person_discounts (создаём)     ТАБЛИЦА pizzeria (уже существует)
┌──────────────────┐                    ┌─────────────┐
│ id               │                    │ id          │ ← СЮДА СМОТРИМ
│ person_id        │                    │ name        │
│ pizzeria_id ─────────────────────────>│ rating      │
│ discount         │                    └─────────────┘
└──────────────────┘
       ↑
   СЛЕВА: pizzeria_id
   (таблица не нужна - мы внутри person_discounts)
   
                                             ↑
                                        СПРАВА: pizzeria(id)
                                        (таблица НУЖНА - это внешняя таблица)
```

## REFERENCES - ПОЧТИ ВЕРНО, НО УТОЧНЮ:

Ты написал:
> REFERENCES даёт возможность связать данные из колонки pizzeria_id из новой таблицы person_discounts с данными из колонки id таблицы pizzeria

**УТОЧНЕНИЕ:**

REFERENCES **не связывает** данные (это делает JOIN).

REFERENCES **ПРОВЕРЯЕТ**, что значение из `pizzeria_id` **СУЩЕСТВУЕТ** в `pizzeria(id)`.

### Разница:

**СВЯЗАТЬ (JOIN)** = показать рядом:
```sql
SELECT * FROM person_discounts 
JOIN pizzeria ON pizzeria.id = person_discounts.pizzeria_id;
```

**ПРОВЕРИТЬ (REFERENCES)** = запретить вставить несуществующее:
```sql
INSERT INTO person_discounts (pizzeria_id, ...) VALUES (999, ...);
                                                        ↑
                                        PostgreSQL проверит: "Есть ли pizzeria с id=999?"
                                        Если НЕТ → ОШИБКА!
```

## ИТОГО - ТЫ ПРАВИЛЬНО ПОНЯЛ:

✓ CONSTRAINT даёт имя правилу
✓ FOREIGN KEY - тип правила
✓ Слева (pizzeria_id) - столбец из ЭТОЙ таблицы
✓ Справа pizzeria(id) - таблица и столбец, куда смотрим

**ПОЧЕМУ СЛЕВА НЕТ ТАБЛИЦЫ:**
Потому что мы ВНУТРИ `CREATE TABLE person_discounts`, PostgreSQL итак знает, что речь про эту таблицу!

**ПОЧЕМУ СПРАВА ЕСТЬ ТАБЛИЦА:**
Потому что это ДРУГАЯ, ВНЕШНЯЯ таблица - нужно указать КАКАЯ именно!

Понятно теперь?











```sql
ТОЕСТЬ АЙДИ ИЗ ТАБЛИЦЫ ПЕРСОНН СВЯЗЫВАЕТСЯ С АЙДИ НОВОЙ ТАБЛИЦЫ ПЕРСОН_ДИСКАУНТ АЙДИ
```


```sql
- тоесть всё это защита от дурака, что бы защитить данные из одной таблицы от односторонних измнений без внесения изменений во вторую таблицу ?? то есть в будущем у меня не получется с помошью 1-ой команды поменять значение в 1 колонке 1 таблицы придётся менять в рамках одной команды сразу 2????
```

правильно ли я понимаю что REFERENCES проверяет занчения только по колонке id в данном запросе ??? ане всей таблицы целиком ?






## 1. СВЯЗЬ МЕЖДУ ТАБЛИЦАМИ - ПОЧТИ ВЕРНО, НО УТОЧНЮ!

```sql
ТАБЛИЦА person               ТАБЛИЦА person_discounts
┌──────────┐                 ┌─────────────────┐
│ id       │ ←───────────────│ person_id       │
│ name     │                 │ pizzeria_id     │
│ age      │                 │ discount        │
└──────────┘                 └─────────────────┘
```

**person.id** связывается с **person_discounts.person_id** (не id, а **person_id**!)

## 2. ЗАЩИТА ОТ ДУРАКА - ДА, НО НЕ ТАК КАК ТЫ ДУМАЕШЬ!

### НЕТ! Не нужно менять сразу в двух таблицах одной командой!

FOREIGN KEY **НЕ ЗАСТАВЛЯЕТ** менять обе таблицы одновременно.

FOREIGN KEY **ЗАПРЕЩАЕТ** только **ОПАСНЫЕ** операции:

### Что ЗАПРЕЩАЕТ FOREIGN KEY:

#### ❌ Нельзя УДАЛИТЬ родителя, пока есть дети:

```sql
-- ТАБЛИЦА person
id | name
1  | Андрей

-- ТАБЛИЦА person_discounts
person_id | скидка
1         | 10%   ← ссылается на Андрея
```

Попытка удалить:
```sql
DELETE FROM person WHERE id = 1;
```

PostgreSQL: **ОШИБКА!** "На Андрея ссылается запись в person_discounts! Сначала удали скидку, потом человека!"

#### ❌ Нельзя ВСТАВИТЬ ребенка, если нет родителя:

```sql
-- ТАБЛИЦА person
id | name
1  | Андрей
2  | Денис
```

Попытка вставить:
```sql
INSERT INTO person_discounts (person_id, скидка) VALUES (999, 50%);
                                                           ↑
                                                 Человека с id=999 НЕТ!
```

PostgreSQL: **ОШИБКА!** "Человека с id=999 не существует!"

### ✅ Что МОЖНО делать СВОБОДНО:

#### ✅ Можно изменить имя Андрея:

```sql
UPDATE person SET name = 'Андрюха' WHERE id = 1;
```

PostgreSQL: **ОК!** Скидка осталась привязана к id=1, имя не важно.

#### ✅ Можно изменить процент скидки:

```sql
UPDATE person_discounts SET discount = 20 WHERE person_id = 1;
```

PostgreSQL: **ОК!** Меняем только скидку, человек остался тот же.

#### ✅ Можно добавить новую скидку:

```sql
INSERT INTO person_discounts (person_id, pizzeria_id, discount) VALUES (1, 2, 15);
```

PostgreSQL: **ОК!** Человек с id=1 существует.

## АНАЛОГИЯ: Паспорт и билеты

**person** = база паспортов
**person_discounts** = билеты на концерт

### FOREIGN KEY - это правило:

❌ **Нельзя** купить билет на имя человека, у которого нет паспорта (нет в базе person)
❌ **Нельзя** уничтожить паспорт человека, у которого есть купленный билет

✅ **Можно** изменить адрес в паспорте (билет остается действительным)
✅ **Можно** сменить место в билете (паспорт не меняется)

## 3. REFERENCES ПРОВЕРЯЕТ ТОЛЬКО ПО СТОЛБЦУ id - ДА! ✓

```sql
REFERENCES pizzeria(id)
                    ↑
            ТОЛЬКО этот столбец!
```

PostgreSQL проверяет **ТОЛЬКО** столбец `id` в таблице `pizzeria`, а **НЕ** всю таблицу целиком.

### Пример:

```sql
-- ТАБЛИЦА pizzeria
id | name       | rating
1  | Dominos    | 4.5
2  | Pizza Hut  | 3.8
3  | Best Pizza | 4.2
```

При вставке:
```sql
INSERT INTO person_discounts (pizzeria_id, ...) VALUES (2, ...);
```

PostgreSQL проверяет:
- Есть ли в столбце **pizzeria.id** значение **2**? ✓ Да → OK
- PostgreSQL **НЕ СМОТРИТ** на name, rating - они НЕ ВАЖНЫ!

При вставке:
```sql
INSERT INTO person_discounts (pizzeria_id, ...) VALUES (999, ...);
```

PostgreSQL проверяет:
- Есть ли в столбце **pizzeria.id** значение **999**? ✗ Нет → **ОШИБКА!**

## ИТОГО:

### 1. Связь таблиц:
**person.id** ↔ **person_discounts.person_id** (не id!)

### 2. Защита от дурака:
- ❌ Нельзя удалить родителя, пока есть дети
- ❌ Нельзя вставить ребенка без родителя
- ✅ Можно менять данные в ОДНОЙ таблице (имя, адрес, скидку и т.д.)
- **НЕ НУЖНО** менять обе таблицы одновременно!

### 3. REFERENCES проверяет:
**ДА!** Только указанный столбец (id), а не всю таблицу.

Понятно?





























## АЛЬТЕРНАТИВНЫЕ СПОСОБЫ СОЗДАНИЯ ТАБЛИЦЫ

### Способ 1: Без явных имен CONSTRAINT (короткий)

```sql
DROP TABLE IF EXISTS person_discounts;

CREATE TABLE person_discounts (
    id BIGINT PRIMARY KEY,
    person_id BIGINT REFERENCES person(id),
    pizzeria_id BIGINT REFERENCES pizzeria(id),
    discount NUMERIC
);

SELECT COUNT(*) = 1 AS check
FROM pg_tables
WHERE tablename = 'person_discounts';
```

**REFERENCES person(id)** — создает внешний ключ БЕЗ явного имени
PostgreSQL сам создаст имя типа: `person_discounts_person_id_fkey`

**Плюсы:**
- Короче, меньше кода
- Быстрее писать

**Минусы:**
- Имена constraint автоматические, сложно искать
- Не соответствует требованиям задания

---

### Способ 2: С добавлением CONSTRAINT через ALTER TABLE

```sql
DROP TABLE IF EXISTS person_discounts;

-- Создаем таблицу БЕЗ ограничений
CREATE TABLE person_discounts (
    id BIGINT,
    person_id BIGINT,
    pizzeria_id BIGINT,
    discount NUMERIC
);

-- Добавляем PRIMARY KEY
ALTER TABLE person_discounts 
    ADD CONSTRAINT pk_person_discounts PRIMARY KEY (id);

-- Добавляем FOREIGN KEY для person_id
ALTER TABLE person_discounts 
    ADD CONSTRAINT fk_person_discounts_person_id 
    FOREIGN KEY (person_id) REFERENCES person(id);

-- Добавляем FOREIGN KEY для pizzeria_id
ALTER TABLE person_discounts 
    ADD CONSTRAINT fk_person_discounts_pizzeria_id 
    FOREIGN KEY (pizzeria_id) REFERENCES pizzeria(id);

SELECT COUNT(*) = 1 AS check
FROM pg_tables
WHERE tablename = 'person_discounts';
```

**ALTER TABLE** — изменяет существующую таблицу
**ADD CONSTRAINT** — добавляет новое ограничение

**Плюсы:**
- Понятно, какое ограничение добавляется
- Можно добавлять ограничения постепенно
- Удобно для миграций

**Минусы:**
- Больше кода
- Медленнее (несколько команд)

---

### Способ 3: С использованием SERIAL для автоинкремента id

```sql
DROP TABLE IF EXISTS person_discounts;

CREATE TABLE person_discounts (
    id BIGSERIAL PRIMARY KEY,
    person_id BIGINT,
    pizzeria_id BIGINT,
    discount NUMERIC,
    CONSTRAINT fk_person_discounts_person_id 
        FOREIGN KEY (person_id) REFERENCES person(id),
    CONSTRAINT fk_person_discounts_pizzeria_id 
        FOREIGN KEY (pizzeria_id) REFERENCES pizzeria(id)
);

SELECT COUNT(*) = 1 AS check
FROM pg_tables
WHERE tablename = 'person_discounts';
```

**BIGSERIAL** — специальный тип, автоматически создает:
1. Столбец типа BIGINT
2. Последовательность (sequence) для автоинкремента
3. DEFAULT NEXTVAL для столбца

**SERIAL** = BIGINT + автоинкремент

**Плюсы:**
- id генерируется автоматически при INSERT
- Не нужно вручную указывать id

**Минусы:**
- В задании требуется BIGINT, не BIGSERIAL

---

### Способ 4: С проверкой существования через IF NOT EXISTS

```sql
DROP TABLE IF EXISTS person_discounts CASCADE;

CREATE TABLE IF NOT EXISTS person_discounts (
    id BIGINT PRIMARY KEY,
    person_id BIGINT,
    pizzeria_id BIGINT,
    discount NUMERIC,
    CONSTRAINT fk_person_discounts_person_id 
        FOREIGN KEY (person_id) REFERENCES person(id),
    CONSTRAINT fk_person_discounts_pizzeria_id 
        FOREIGN KEY (pizzeria_id) REFERENCES pizzeria(id)
);

SELECT COUNT(*) = 1 AS check
FROM pg_tables
WHERE tablename = 'person_discounts';
```

**IF NOT EXISTS** — создает таблицу только если её нет
**CASCADE** — при DROP удаляет зависимые объекты (views, foreign keys из других таблиц)

**Плюсы:**
- Безопасно (не выдаст ошибку, если таблица уже есть)
- CASCADE удаляет зависимости

**Минусы:**
- Может скрыть проблемы (не узнаешь, что таблица уже была)

---

### Способ 5: С явным указанием схемы (schema)

```sql
DROP TABLE IF EXISTS public.person_discounts;

CREATE TABLE public.person_discounts (
    id BIGINT PRIMARY KEY,
    person_id BIGINT,
    pizzeria_id BIGINT,
    discount NUMERIC,
    CONSTRAINT fk_person_discounts_person_id 
        FOREIGN KEY (person_id) REFERENCES public.person(id),
    CONSTRAINT fk_person_discounts_pizzeria_id 
        FOREIGN KEY (pizzeria_id) REFERENCES public.pizzeria(id)
);

SELECT COUNT(*) = 1 AS check
FROM pg_tables
WHERE schemaname = 'public' 
  AND tablename = 'person_discounts';
```

**public** — имя схемы по умолчанию в PostgreSQL
**Схема** (schema) — пространство имен для таблиц (как папка для файлов)

**Плюсы:**
- Явно указано, где создается таблица
- Полезно при работе с несколькими схемами

**Минусы:**
- Избыточно для простых проектов

---

### Способ 6: С действиями при удалении (ON DELETE)

```sql
DROP TABLE IF EXISTS person_discounts;

CREATE TABLE person_discounts (
    id BIGINT PRIMARY KEY,
    person_id BIGINT,
    pizzeria_id BIGINT,
    discount NUMERIC,
    CONSTRAINT fk_person_discounts_person_id 
        FOREIGN KEY (person_id) REFERENCES person(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_person_discounts_pizzeria_id 
        FOREIGN KEY (pizzeria_id) REFERENCES pizzeria(id)
        ON DELETE CASCADE
);

SELECT COUNT(*) = 1 AS check
FROM pg_tables
WHERE tablename = 'person_discounts';
```

**ON DELETE CASCADE** — автоматически удаляет скидки при удалении клиента или пиццерии

**Варианты ON DELETE:**
- **CASCADE** — удалить зависимые строки
- **SET NULL** — установить NULL в зависимых строках
- **SET DEFAULT** — установить DEFAULT значение
- **RESTRICT** — запретить удаление (по умолчанию)
- **NO ACTION** — то же что RESTRICT

**Плюсы:**
- Автоматическая очистка данных
- Защита от "висящих" ссылок

**Минусы:**
- Можно случайно удалить важные данные

---

### Способ 7: С DEFAULT значениями и CHECK constraints

```sql
DROP TABLE IF EXISTS person_discounts;

CREATE TABLE person_discounts (
    id BIGINT PRIMARY KEY,
    person_id BIGINT NOT NULL,
    pizzeria_id BIGINT NOT NULL,
    discount NUMERIC DEFAULT 0 CHECK (discount BETWEEN 0 AND 100),
    CONSTRAINT fk_person_discounts_person_id 
        FOREIGN KEY (person_id) REFERENCES person(id),
    CONSTRAINT fk_person_discounts_pizzeria_id 
        FOREIGN KEY (pizzeria_id) REFERENCES pizzeria(id)
);

SELECT COUNT(*) = 1 AS check
FROM pg_tables
WHERE tablename = 'person_discounts';
```

**NOT NULL** — запрещает пустые значения
**DEFAULT 0** — значение по умолчанию
**CHECK (discount BETWEEN 0 AND 100)** — проверяет диапазон значений

**Плюсы:**
- Больше защиты от некорректных данных
- Значения по умолчанию упрощают INSERT

**Минусы:**
- Больше ограничений = меньше гибкости

---

### Способ 8: С именованным PRIMARY KEY

```sql
DROP TABLE IF EXISTS person_discounts;

CREATE TABLE person_discounts (
    id BIGINT,
    person_id BIGINT,
    pizzeria_id BIGINT,
    discount NUMERIC,
    CONSTRAINT pk_person_discounts PRIMARY KEY (id),
    CONSTRAINT fk_person_discounts_person_id 
        FOREIGN KEY (person_id) REFERENCES person(id),
    CONSTRAINT fk_person_discounts_pizzeria_id 
        FOREIGN KEY (pizzeria_id) REFERENCES pizzeria(id)
);

SELECT COUNT(*) = 1 AS check
FROM pg_tables
WHERE tablename = 'person_discounts';
```

**CONSTRAINT pk_person_discounts PRIMARY KEY (id)** — явное имя для PRIMARY KEY

**Плюсы:**
- Все constraint с понятными именами
- Единый стиль именования

**Минусы:**
- Чуть длиннее код

---

### Способ 9: С составным первичным ключом (вместо id)

```sql
DROP TABLE IF EXISTS person_discounts;

CREATE TABLE person_discounts (
    person_id BIGINT,
    pizzeria_id BIGINT,
    discount NUMERIC,
    CONSTRAINT pk_person_discounts PRIMARY KEY (person_id, pizzeria_id),
    CONSTRAINT fk_person_discounts_person_id 
        FOREIGN KEY (person_id) REFERENCES person(id),
    CONSTRAINT fk_person_discounts_pizzeria_id 
        FOREIGN KEY (pizzeria_id) REFERENCES pizzeria(id)
);

SELECT COUNT(*) = 1 AS check
FROM pg_tables
WHERE tablename = 'person_discounts';
```

**PRIMARY KEY (person_id, pizzeria_id)** — составной первичный ключ из двух столбцов

**Составной ключ** — когда уникальность обеспечивается комбинацией нескольких столбцов

**Плюсы:**
- Не нужен искусственный id
- Пара (person_id, pizzeria_id) и так уникальна

**Минусы:**
- В задании требуется столбец id
- Сложнее ссылаться на эту таблицу из других таблиц

---

### Способ 10: С созданием индексов

```sql
DROP TABLE IF EXISTS person_discounts;

CREATE TABLE person_discounts (
    id BIGINT PRIMARY KEY,
    person_id BIGINT,
    pizzeria_id BIGINT,
    discount NUMERIC,
    CONSTRAINT fk_person_discounts_person_id 
        FOREIGN KEY (person_id) REFERENCES person(id),
    CONSTRAINT fk_person_discounts_pizzeria_id 
        FOREIGN KEY (pizzeria_id) REFERENCES pizzeria(id)
);

-- Создаем индексы для ускорения поиска
CREATE INDEX idx_person_discounts_person_id 
    ON person_discounts(person_id);

CREATE INDEX idx_person_discounts_pizzeria_id 
    ON person_discounts(pizzeria_id);

SELECT COUNT(*) = 1 AS check
FROM pg_tables
WHERE tablename = 'person_discounts';
```

**CREATE INDEX** — создает индекс для ускорения поиска
**Индекс** — структура данных для быстрого поиска (как предметный указатель в книге)

**Плюсы:**
- Ускоряет JOIN и WHERE по этим столбцам
- Рекомендуется для внешних ключей

**Минусы:**
- Занимает место на диске
- Замедляет INSERT/UPDATE/DELETE

---

## СРАВНЕНИЕ СПОСОБОВ

| Способ | Сложность | Безопасность | Производительность | Соответствие заданию |
|--------|-----------|--------------|-------------------|---------------------|
| **Оригинал** | Низкая | Средняя | Высокая | ✓ Полное |
| **Без CONSTRAINT** | Очень низкая | Низкая | Высокая | ✗ Нет явных имен |
| **ALTER TABLE** | Средняя | Средняя | Средняя | ✓ Полное |
| **BIGSERIAL** | Низкая | Средняя | Высокая | ✗ Тип не BIGINT |
| **IF NOT EXISTS** | Низкая | Высокая | Высокая | ✓ Полное |
| **С схемой** | Низкая | Средняя | Высокая | ✓ Полное |
| **ON DELETE CASCADE** | Низкая | Высокая | Высокая | ✓ Полное |
| **С CHECK** | Средняя | Очень высокая | Средняя | ✓ Улучшенное |
| **Именованный PK** | Низкая | Средняя | Высокая | ✓ Полное |
| **Составной ключ** | Средняя | Средняя | Высокая | ✗ Нет id |
| **С индексами** | Средняя | Средняя | Очень высокая | ✓ Улучшенное |

---

## РЕКОМЕНДАЦИЯ ДЛЯ ЗАЩИТЫ

**Оригинальный способ — правильный выбор**, потому что:
1. Соответствует требованиям задания
2. Явные имена CONSTRAINT
3. Простой и понятный

**Если спросят "почему не ALTER TABLE?":**
> "ALTER TABLE используется, когда таблица уже существует и нужно добавить ограничения позже. При создании новой таблицы удобнее объявить все ограничения сразу в CREATE TABLE — это быстрее и понятнее."

**Если спросят "почему не BIGSERIAL?":**
> "BIGSERIAL автоматически создает последовательность и генерирует id. Но в задании явно требуется BIGINT, а автоинкремент настраивается отдельно через SEQUENCE в следующем задании."

**Если спросят "зачем DROP IF EXISTS?":**
> "Это обеспечивает идемпотентность скрипта — его можно запускать многократно без ошибок. Если таблица уже есть, она сначала удалится, потом создастся заново."