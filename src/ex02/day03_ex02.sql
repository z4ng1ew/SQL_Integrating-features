SELECT 
    pers.name, 
    menu.pizza_name, 
    menu.price, 
    (menu.price - (menu.price * disc.discount / 100)) AS discount_price, 
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
ORDER BY 1, 2;