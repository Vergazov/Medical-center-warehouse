use medical_center_warehouse;

DELIMITER $$

-- Список номенклатуры с фильтрацией

CREATE DEFINER=`root`@`%` PROCEDURE `get_items`(
IN p_item_name VARCHAR(255),
IN p_type_id INT,
IN p_spec_ids VARCHAR(50),
IN p_comment TEXT,
IN p_soft_deletes INT, -- 1 - with soft deletes, 2 - only soft deletes, null - without soft deletes
IN p_sort_column VARCHAR(50),
IN p_sort_direction VARCHAR(4),
IN p_page INT,
IN p_page_size INT
)
BEGIN

	DECLARE v_sort_column VARCHAR(50);
    DECLARE v_sort_direction VARCHAR(4);
	DECLARE v_page INT;
    DECLARE v_page_size INT;
    DECLARE v_offset INT;
	DECLARE v_soft_deletes INT;
    
	SET v_sort_column = CASE
		WHEN p_sort_column = 'name' THEN 'i.name'
        WHEN p_sort_column = 'type' THEN 't.name'
        WHEN p_sort_column = 'spec' THEN 's.name'
        ELSE 'i.id'
	END;
    
	SET v_sort_direction = CASE
		WHEN UPPER(p_sort_direction) = 'DESC' THEN 'DESC'
        ELSE 'ASC'
	END;
    
     SET v_page = CASE -- номер страницы
        WHEN p_page IS NULL OR p_page < 1 THEN 1 -- если не передан или меньше 1 то, ставим 1
        ELSE p_page -- иначе ставим тот который передал пользователь
    END;

    SET v_page_size = CASE -- размер одной страницы
        WHEN p_page_size IS NULL OR p_page_size < 1 THEN 20 -- если page_size не передан или он меньше 1, то ставим дефолтный в 20
        WHEN p_page_size > 50 THEN 50 -- если переданный больше тысячи то ставим 100
        ELSE p_page_size -- иначе ставим тот который передал пользователь
    END;

    SET v_offset = (v_page - 1) * v_page_size;
    -- считаем смещение
    -- формула: (номер страницы - 1) умножить на размер страницы
    -- пример: 
    -- мне нужна 3 страница, 30 элементов
    -- (3-1) * 30
    -- v_offset = 60
    -- то есть мы пропускаем 60 записей( 2 страницы) начинаем с 61 и выводим 30 записей

	SET @sql = '
		SELECT
			i.id,
            i.name,
            u.name as unit_name,
            t.name as type_name,
            i.inv_number,
            i.serial_number,
            i.comment,
            s.name as spec_name
		FROM items i
        LEFT JOIN units u on i.unit_id = u.id
        LEFT JOIN types t on i.type_id = t.id
        LEFT JOIN items_specs isp ON i.id = isp.item_id
        LEFT JOIN specialties s  ON isp.spec_id = s.id
        WHERE 1=1
    ';

    IF p_item_name IS NOT NULL AND p_item_name != '' THEN
		  SET @sql = CONCAT(
        @sql, ' AND MATCH(i.name) AGAINST (', QUOTE(CONCAT(p_item_name, '*')), ' IN BOOLEAN MODE)');
	END IF;
    
	IF p_type_id IS NOT NULL THEN
		SET @sql = CONCAT(@sql, ' AND t.id = ', p_type_id);
	END IF;
    
	 -- фильтр по нескольким специальностям
     IF p_spec_ids IS NOT NULL THEN
		SET @sql = CONCAT(@sql, ' AND s.id in (', p_spec_ids, ')');
     END IF;
    
	IF p_comment IS NOT NULL AND p_comment != ''  THEN
		    SET @sql = CONCAT(@sql, ' AND MATCH(i.comment) AGAINST(', QUOTE(CONCAT(p_comment, '*')), ' IN BOOLEAN MODE)');
	END IF;
    
    SET @sql = CONCAT(
		@sql,
		CASE
			WHEN p_soft_deletes = 1 THEN ' OR deleted_at IS NOT NULL'
			WHEN p_soft_deletes = 2 THEN ' AND deleted_at IS NOT NULL'
			ELSE ' AND deleted_at IS NULL'
		END
	); 
    
    SET @sql = CONCAT(@sql, ' GROUP BY i.id, s.name ');
    
	SET @sql = CONCAT(
        @sql,
        ' ORDER BY ', v_sort_column, ' ', v_sort_direction, 
        ' LIMIT ', v_page_size, 
        ' OFFSET ', v_offset
    );
    
    SELECT @sql;
	PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
END $$

-- Отчет по движению товаров

CREATE DEFINER=`root`@`%` PROCEDURE `get_items_movement`()
BEGIN
    WITH t_purchases AS(
        SELECT 
            i.id,
            i.name,
            p.created_at,
            p.amount,
            'Приход' TYPE
        FROM items i
        JOIN purchases p ON p.item_id = i.id
    ),
    t_expenses AS(
        SELECT 
            i.id,
            i.name,
            e.created_at,
            - e.amount,
            'Расход' TYPE
        FROM items i
        JOIN expenses e ON e.item_id = i.id
    ),
    movements AS(
        SELECT * FROM t_purchases
        UNION ALL
        SELECT * FROM t_expenses
    )
    SELECT name,
        created_at,
        amount,
        SUM(amount) over(
            PARTITION by id
            ORDER BY created_at ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS total,
        TYPE
    FROM movements;
END $$

-- Отчет по номенклатуре с истекшим сроком годности

CREATE DEFINER=`root`@`%` PROCEDURE `get_expired_items`()
BEGIN
SELECT 
	i.id,
	i.name,
	p.expires_at
FROM items i
JOIN purchases p ON p.item_id = i.id
WHERE 1 = 1
AND p.deleted_at IS NULL
AND p.expires_at < NOW()
ORDER BY i.id;
END $$

-- Отчет по номенклатуре у которой скоро истечет срок годности

CREATE DEFINER=`root`@`%` PROCEDURE `get_soon_expired_items`()
BEGIN
SELECT 
	i.id,
	i.name,
	p.expires_at
FROM items i
JOIN purchases p ON p.item_id = i.id
WHERE p.expires_at BETWEEN NOW()
AND NOW() + INTERVAL 30 DAY
ORDER BY i.id;

END  $$

-- Отчет по остаткам на складах

CREATE DEFINER=`root`@`%` PROCEDURE `get_storage_balance`()
BEGIN
	WITH purchases_balance AS (
		SELECT 
			i.id,
			i.name,
			sum(p.amount) AS purchases
		FROM items i
		JOIN purchases p ON p.item_id = i.id
		WHERE p.deleted_at IS NULL
		GROUP BY i.id
	),
	purchases_with_expenses_balance AS (
		SELECT 
			p.name,
			purchases,
			sum(e.amount) AS expenses
		FROM purchases_balance p
		JOIN expenses e ON e.item_id = p.id
		WHERE e.deleted_at IS NULL
		GROUP BY p.id
	)
	SELECT 
    b.*,
    (purchases - expenses) AS total
	FROM purchases_with_expenses_balance b
	ORDER BY name;
END $$

DELIMITER ;