-- все остатки на складах
CREATE DEFINER=`root`@`%` PROCEDURE `get_storage_balance`()
BEGIN
	WITH parishes_balance AS (
		SELECT 
			n.id,
			n.name,
			sum(p.amount) AS parishes
		FROM nomenclatures n
		JOIN parishes p ON p.nomenclature_id = n.id
		WHERE p.deleted_at IS NULL
		GROUP BY n.name, n.id
		ORDER BY n.id
	),
	parishes_with_cancellations_balance AS (
		SELECT 
			p.name,
			parishes,
			sum(c.amount) AS cancellations
		FROM parishes_balance p
		JOIN cancellations c ON c.nomenclature_id = p.id
		WHERE c.deleted_at IS NULL
		GROUP BY p.name, parishes
	)
	SELECT 
    b.*,
    (parishes - cancellations) AS total
	FROM parishes_with_cancellations_balance b
	ORDER BY name;
END

-- просроченная номенклатура
CREATE DEFINER=`root`@`%` PROCEDURE `get_expired_nomenclature`()
BEGIN
SELECT 
	n.id,
	n.name,
	p.expires_at
FROM nomenclatures n
JOIN parishes p ON p.nomenclature_id = n.id
WHERE 1 = 1
AND p.deleted_at IS NULL
AND expires_at < NOW()
ORDER BY n.id;
END

-- номеенклатура со сроком годности менее 30 дней
CREATE DEFINER=`root`@`%` PROCEDURE `get_soon_expired_nomenclature`()
BEGIN
SELECT 
	n.id,
	n.name,
	p.expires_at
FROM nomenclatures n
JOIN parishes p ON p.nomenclature_id = n.id
WHERE expires_at BETWEEN NOW()
AND NOW() + INTERVAL 30 DAY
ORDER BY n.id;

END

-- движение номенклатуры
CREATE DEFINER=`root`@`%` PROCEDURE `get_nomenclature_movement`()
BEGIN
WITH t_parishes AS(
	SELECT 
		n.name,
		p.created_at,
		p.amount,
		'Приход' TYPE
	FROM nomenclatures n
	JOIN parishes p ON p.nomenclature_id = n.id
),
t_cancellations AS(
	SELECT 
		n.name,
		c.created_at,
		- c.amount,
		'Расход' TYPE
	FROM nomenclatures n
	JOIN cancellations c ON c.nomenclature_id = n.id
),
movements AS(
	SELECT * FROM t_parishes
	UNION ALL
	SELECT * FROM t_cancellations
)
SELECT name,
	created_at,
	amount,
	SUM(amount) over(
		PARTITION by name
		ORDER BY created_at ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
	) AS total,
	TYPE
FROM movements;
END