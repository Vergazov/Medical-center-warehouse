# DML: агрегация и сортировка в MySQL

## Группировки с ипользованием CASE, HAVING, ROLLUP, GROUPING() :

> Посчитать какое кол-во товаров в каждой категории имеет цену больше 400
```sql
SELECT category,
	sum(
		CASE
			WHEN price > 400 THEN 1
			ELSE 0
		END
	) AS COUNT
FROM products
GROUP BY category;
```

> Вывести рейтинг который был выставлен больше 2 раз
```sql
SELECT rating,
	COUNT(*) AS cnt
FROM products
GROUP BY rating
HAVING cnt > 2;
```

> Посчитать общее кол-во статусов
```sql
SELECT IF(grouping(STATUS), 'Итого', STATUS) AS STATUS,
	COUNT(*)
FROM products
GROUP BY STATUS WITH rollup;
```

## Для магазина к предыдущему списку продуктов добавить максимальную и минимальную цену и кол-во предложений
```sql
SELECT *,
	max(price) over() AS max_price,
	min(price) over() AS min_price,
	CASE
		WHEN STATUS = 'В наличии' THEN 1
		ELSE 0
	END AS demand
FROM products
```

## Сделать выборку показывающую самый дорогой и самый дешевый товар в каждой категории
```sql
WITH ranked AS (
    SELECT 
        category,
        MAX(CASE WHEN rn_desc = 1 THEN title END) AS max_name,
        MAX(CASE WHEN rn_desc = 1 THEN price END) AS max_price,
        MAX(CASE WHEN rn_asc = 1 THEN title END) AS min_name,
        MAX(CASE WHEN rn_asc = 1 THEN price END) AS min_price
    FROM (
        SELECT *,
			row_number() over(partition by(category) order by price desc) as rn_desc,
			row_number() over(partition by(category) order by price asc) as rn_asc
        FROM products
    ) t
    GROUP BY category
)
SELECT * FROM ranked;
```

## Сделать rollup с количеством товаров по категориям

```sql 
SELECT 
IF(grouping(category), 'ИТОГО', category) AS category,
COUNT(*) AS count_products
FROM products
GROUP BY category WITH rollup;
```
