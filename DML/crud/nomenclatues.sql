-- CRUD операции над сущностью Nomenclatures

/**
Процедура для получения информации о всех позициях номенклатуры:

Фильтры по полям:
    - имя
    - тип
    - специльность
    - коментарий
 
Указать включать ли в выборку архивированные записи при помоши параметра p_soft_deletes:
    - 1 - включить архивированнные записи в выборку 
    - 2 - показать только архивированные записи
    - null - не показывать архивированные записи

Указать поле для сортировки
    - p_sort_column, разрешенные поля - name, type, spec, по умолчанию - id

Указать направление сортировки
    - p_sort_direction - разрешенные значения - DESC, по умолчанию ASC

Пагинация:
    Указать номер страницы - p_page
    Указать размер страницы - p_page_size. Максимальный размер - 50 строк, дефолтный - 20
*/
CREATE DEFINER=`root`@`%` PROCEDURE `get_nomenclatures`(
IN p_nomenclature_name VARCHAR(255),
IN p_type_id INT,
IN p_spec_id INT,
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
		WHEN p_sort_column = 'name' THEN 'n.name'
        WHEN p_sort_column = 'type' THEN 't.name'
        WHEN p_sort_column = 'spec' THEN 's.name'
        ELSE 'n.id'
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
			n.id,
            n.name,
            u.name as unit_name,
            t.name as type_name,
            s.name as spec_name,
            n.inv_number,
            n.serial_number,
            n.comment
		FROM nomenclatures as n
        JOIN units u on n.unit_id = u.id
        JOIN types t on n.type_id = t.id
        JOIN specialties s on n.spec_id = s.id
        WHERE 1=1
    ';
    
    -- TODO: fulltext index
    IF p_nomenclature_name IS NOT NULL AND p_nomenclature_name != '' THEN
		SET @sql = CONCAT(@sql, ' AND n.name like ', QUOTE(CONCAT('%', p_nomenclature_name, '%')));
	END IF;
    
	IF p_type_id IS NOT NULL THEN
		SET @sql = CONCAT(@sql, ' AND t.id = ', p_type_id);
	END IF;
    
	IF p_spec_id IS NOT NULL THEN
		SET @sql = CONCAT(@sql, ' AND s.id = ', p_spec_id);
	END IF;
    
    -- TODO: fulltext index
	IF p_comment IS NOT NULL AND p_comment != ''  THEN
		SET @sql = CONCAT(@sql, ' AND n.comment like ', QUOTE(CONCAT('%', p_comment, '%')));
	END IF;
    
    SET @sql = CONCAT(
		@sql,
		CASE
			WHEN p_soft_deletes = 1 THEN ' OR deleted_at IS NOT NULL'
			WHEN p_soft_deletes = 2 THEN ' AND deleted_at IS NOT NULL'
			ELSE ' AND deleted_at IS NULL'
		END
	);  
    
	SET @sql = CONCAT(
        @sql,
        ' ORDER BY ', v_sort_column, ' ', v_sort_direction, 
        ' LIMIT ', v_page_size, 
        ' OFFSET ', v_offset
    );
    
	PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END


/**
Процедура для создания новой номенклатуры

Обязательно передаем user_id для логирования
*/

CREATE DEFINER=`root`@`%` PROCEDURE `create_nomenclature`(
IN p_name VARCHAR(255),
IN p_unit_id INT,
IN p_type_id INT,
IN p_spec_id INT,
IN p_user_id INT,
IN p_inv_number VARCHAR(100),
IN p_serial_number VARCHAR(100),
IN p_comment VARCHAR(255)
)
BEGIN
	
	DECLARE v_user_name VARCHAR(100);
    DECLARE v_user_birth_date VARCHAR(100);
    DECLARE v_nomenclature_id INT UNSIGNED;
    
	-- 45000 специальный код SQLSTATE в MySQL, который означает user-defined exception
	IF p_name IS NULL OR p_name = ''  THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указано имя номенклатуры';
	END IF;

	IF p_type_id IS NULL THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указан тип номенклатуры';
	END IF;

	IF p_unit_id IS NULL THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указана единица измерения';
	END IF;

	IF p_spec_id IS NULL THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указана специальность';
	END IF;
    
	IF p_user_id IS NULL THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указан пользователь';
	END IF;
    
    SELECT name, birth_date
    INTO v_user_name, v_user_birth_date
    FROM employees
    WHERE id = p_user_id
    LIMIT 1;

    IF v_user_name IS NULL OR v_user_name = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Пользователь не найден';
    END IF;
    
    START TRANSACTION;

	INSERT INTO nomenclatures(
        name,
        unit_id,
        type_id,
        spec_id,
        inv_number,
        serial_number,
        comment
    )
    VALUES (
        p_name,
        p_unit_id,
        p_type_id,
        p_spec_id,
        p_inv_number,
        p_serial_number,
        p_comment
    );
    
    SET v_nomenclature_id = LAST_INSERT_ID();
    SELECT name, birth_date INTO v_user_name, v_user_birth_date FROM employees WHERE id = p_user_id;
    
	INSERT INTO action_logs(atype,log) 
    VALUES
    (1, CONCAT('Пользователь ', v_user_name,'(',v_user_birth_date, ')', ' создал номенклатуру ', QUOTE(p_name),' id:(',v_nomenclature_id,')' ));

    COMMIT;
END

/**
Процедура для получения номенклатуры по id
*/

CREATE DEFINER=`root`@`%` PROCEDURE `show_nomenclature`(IN p_id INT)
BEGIN
	SELECT
		n.id,
		n.name,
		u.name as unit_name,
		t.name as type_name,
		s.name as spec_name,
		n.inv_number,
		n.serial_number,
		n.comment
	FROM nomenclatures as n
	JOIN units u on n.unit_id = u.id
	JOIN types t on n.type_id = t.id
	JOIN specialties s on n.spec_id = s.id
	WHERE 1=1
    AND n.id = p_id;
END


/**
Процедура для редактирования номенклатуры
*/

CREATE DEFINER=`root`@`%` PROCEDURE `update_nomenclature`(
IN p_nomenclature_id INT,
IN p_name VARCHAR(255),
IN p_unit_id INT,
IN p_type_id INT,
IN p_spec_id INT,
IN p_user_id INT,
IN p_inv_number VARCHAR(100),
IN p_serial_number VARCHAR(100),
IN p_comment VARCHAR(255)
)
BEGIN
	DECLARE v_user_name VARCHAR(100);
    DECLARE v_user_birth_date VARCHAR(100);
    DECLARE v_updated_count INT;
    DECLARE v_nomenclature_count INT;
        
	IF p_user_id IS NULL THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указан пользователь';
	END IF;
    
    SELECT name, birth_date
    INTO v_user_name, v_user_birth_date
    FROM employees
    WHERE id = p_user_id
    LIMIT 1;
    
	IF v_user_name IS NULL OR v_user_name = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Пользователь не найден';
    END IF;
    
    SELECT COUNT(*) INTO v_nomenclature_count FROM nomenclatures
    WHERE id = p_nomenclature_id;
    
    IF v_nomenclature_count = 0 THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Такой номенклатуры не существует';
	END IF;
    
    START TRANSACTION;
    
    UPDATE nomenclatures 
    SET
		name = COALESCE(p_name, name),
        unit_id = COALESCE(p_unit_id, unit_id),
        type_id = COALESCE(p_type_id, type_id),
        spec_id = COALESCE(p_spec_id, spec_id),
        inv_number = COALESCE(p_inv_number, inv_number),
        serial_number = COALESCE(p_serial_number, serial_number),
        comment = COALESCE(p_comment, comment),
        updated_at = NOW()
	WHERE nomenclatures.id = p_nomenclature_id;
        
	SELECT name, birth_date INTO v_user_name, v_user_birth_date FROM employees WHERE id = p_user_id;
    
	INSERT INTO action_logs(atype,log) VALUES(11, CONCAT('Пользователь ', v_user_name,'(',v_user_birth_date, ')', ' отредактировал номенклатуру с id',' id:(',p_nomenclature_id,')' ));
	
    COMMIT;
END;



/**
Процедура архивирования номенклатуры
*/

CREATE DEFINER=`root`@`%` PROCEDURE `delete_nomenclature`(IN p_nomenclature_id INT, IN p_user_id INT)
BEGIN

	DECLARE v_user_name VARCHAR(100);
    DECLARE v_user_birth_date VARCHAR(100);
    DECLARE v_nomenclature_count INT;
    
    IF p_user_id IS NULL THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указан пользователь';
	END IF;
    
    SELECT name, birth_date
    INTO v_user_name, v_user_birth_date
    FROM employees
    WHERE id = p_user_id
    LIMIT 1;
    
	IF v_user_name IS NULL OR v_user_name = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Пользователь не найден';
    END IF;
    
	IF p_nomenclature_id IS NULL THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указана номенклатура';
	END IF;

	SELECT COUNT(*) INTO v_nomenclature_count FROM nomenclatures
    WHERE 1=1
    AND id = p_nomenclature_id
    AND deleted_at IS NULL;
    
    IF v_nomenclature_count = 0 THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Такой номенклатуры не существует или она уже архивирована';
	END IF;

    START TRANSACTION;
    
	UPDATE nomenclatures
		SET deleted_at = now()
		WHERE nomenclatures.id = p_nomenclature_id;
        
	INSERT INTO action_logs(atype,log) VALUES(11, CONCAT('Пользователь ', v_user_name,'(',v_user_birth_date, ')', ' архивировал номенклатуру с id - ',p_nomenclature_id ));
	
    COMMIT;
END

/**
Процедура разархивирования номенклатуры
*/

CREATE DEFINER=`root`@`%` PROCEDURE `restore_nomenclature`(IN p_nomenclature_id INT, IN p_user_id INT)
BEGIN
	DECLARE v_user_name VARCHAR(100);
    DECLARE v_user_birth_date VARCHAR(100);
    DECLARE v_nomenclature_count INT;
    
    IF p_user_id IS NULL THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указан пользователь';
	END IF;
    
    SELECT name, birth_date
    INTO v_user_name, v_user_birth_date
    FROM employees
    WHERE id = p_user_id
    LIMIT 1;
    
	IF v_user_name IS NULL OR v_user_name = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Пользователь не найден';
    END IF;
    
	IF p_nomenclature_id IS NULL THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указана номенклатура';
	END IF;

	SELECT COUNT(*) INTO v_nomenclature_count FROM nomenclatures
    WHERE 1=1
    AND id = p_nomenclature_id
    AND deleted_at IS NOT NULL;
    
    IF v_nomenclature_count = 0 THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Такой номенклатуры не существует или она не была архивирована';
	END IF;

    START TRANSACTION;
    
	UPDATE nomenclatures
		SET deleted_at = NULL
		WHERE nomenclatures.id = p_nomenclature_id;
        
	INSERT INTO action_logs(atype,log) VALUES(4, CONCAT('Пользователь ', v_user_name,'(',v_user_birth_date, ')', ' разархивировал номенклатуру с id - ',p_nomenclature_id ));
	-- TODO - если эта позиция - единственная на всю накладную, значит надо разархивировать и саму накладную (она скорее всего тогда тоже в архиве)
    COMMIT;
END