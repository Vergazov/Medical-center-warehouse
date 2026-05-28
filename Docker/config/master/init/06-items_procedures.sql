use medical_center_warehouse;

DELIMITER $$

-- Создать номенклатуру

CREATE DEFINER=`root`@`%` PROCEDURE `create_item`(
    IN p_name VARCHAR(255),
    IN p_unit_id INT,
    IN p_type_id INT,
    IN p_spec_ids JSON,
    IN p_user_id INT,
    IN p_inv_number VARCHAR(100),
    IN p_serial_number VARCHAR(100),
    IN p_comment VARCHAR(255)
)
BEGIN
    DECLARE v_user_name VARCHAR(100);
    DECLARE v_user_birth_date VARCHAR(100);
    DECLARE v_item_id INT UNSIGNED;
	DECLARE v_count INT;
    DECLARE error_message TEXT;
    DECLARE v_expected_error BOOLEAN DEFAULT FALSE;
    
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1 
			error_message = MESSAGE_TEXT;
        
        ROLLBACK;
        
		IF v_expected_error = TRUE THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = error_message;
		ELSE
			INSERT INTO error_logs(log) VALUES(error_message);
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Произошла ошибка при выполнении процедуры';
        END IF;
    END;
    
	IF p_name IS NULL OR p_name = ''  THEN
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указано имя номенклатуры';
	END IF;

	IF p_type_id IS NULL THEN
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указан тип номенклатуры';
	END IF;

	IF p_unit_id IS NULL THEN
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указана единица измерения';
	END IF;

	IF p_spec_ids IS NULL THEN
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указана специальность';
	END IF;
    
	IF p_user_id IS NULL THEN
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указан пользователь';
	END IF;
    
    SELECT name, birth_date
    INTO v_user_name, v_user_birth_date
    FROM employees
    WHERE id = p_user_id
    LIMIT 1;

    IF v_user_name IS NULL OR v_user_name = '' THEN
		SET v_expected_error = TRUE;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Пользователь не найден';
    END IF;
    
    START TRANSACTION;

	INSERT INTO items(
        name,
        unit_id,
        type_id,
        inv_number,
        serial_number,
        comment
    )
    VALUES (
        p_name,
        p_unit_id,
        p_type_id,
        p_inv_number,
        p_serial_number,
        p_comment
    );
    
    SET v_item_id = LAST_INSERT_ID();
    
    SET v_count = JSON_LENGTH(p_spec_ids);
    
	INSERT INTO items_specs(item_id, spec_id)
    SELECT v_item_id, jt.spec_id
    FROM JSON_TABLE(p_spec_ids, '$[*]' COLUMNS (spec_id INT PATH '$')) AS jt;
    
	INSERT INTO action_logs(atype,log) 
    VALUES
    (1, CONCAT('Пользователь ', v_user_name,'(',v_user_birth_date, ')', ' создал номенклатуру ', QUOTE(p_name),' id:(',v_item_id,')' ));

    COMMIT;

    SELECT 100 AS status;
END $$

-- Архивировать номенклатуру

CREATE DEFINER=`root`@`%` PROCEDURE `delete_item`(
    IN p_item_id INT,
    IN p_user_id INT
)
BEGIN

	DECLARE v_user_name VARCHAR(100);
    DECLARE v_user_birth_date VARCHAR(100);
    DECLARE v_item_count INT;
    DECLARE error_message TEXT;
    DECLARE v_expected_error BOOLEAN DEFAULT FALSE;
    
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1 
			error_message = MESSAGE_TEXT;
        
        ROLLBACK;
        
		IF v_expected_error = TRUE THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = error_message;
		ELSE
			INSERT INTO error_logs(log) VALUES(error_message);
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Произошла ошибка при выполнении процедуры';
        END IF;
    END;
    
    IF p_user_id IS NULL THEN
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указан пользователь';
	END IF;
    
    SELECT name, birth_date
    INTO v_user_name, v_user_birth_date
    FROM employees
    WHERE id = p_user_id
    LIMIT 1;
    
	IF v_user_name IS NULL OR v_user_name = '' THEN
		SET v_expected_error = TRUE;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Пользователь не найден';
    END IF;
    
	IF p_item_id IS NULL THEN
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указана номенклатура';
	END IF;

	SELECT COUNT(*) INTO v_item_count FROM items
    WHERE 1=1
    AND id = p_item_id
    AND deleted_at IS NULL;
    
    IF v_item_count = 0 THEN 
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Такой номенклатуры не существует или она уже архивирована';
	END IF;

    START TRANSACTION;
    
	UPDATE items
		SET deleted_at = now()
		WHERE id = p_item_id;
        
	INSERT INTO action_logs(atype,log) VALUES(3, CONCAT('Пользователь ', v_user_name,'(',v_user_birth_date, ')', ' архивировал номенклатуру с id - ',p_item_id ));
	
    COMMIT;

    SELECT 100 AS status;
END $$

-- Восстановить номенклатуру

CREATE DEFINER=`root`@`%` PROCEDURE `restore_item`(IN p_items_id INT, IN p_user_id INT)
BEGIN
	DECLARE v_user_name VARCHAR(100);
    DECLARE v_user_birth_date VARCHAR(100);
    DECLARE v_items_count INT;
	DECLARE error_message TEXT;
    DECLARE v_expected_error BOOLEAN DEFAULT FALSE;
    
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1 
			error_message = MESSAGE_TEXT;
        
        ROLLBACK;
        
		IF v_expected_error = TRUE THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = error_message;
		ELSE
			INSERT INTO error_logs(log) VALUES(error_message);
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Произошла ошибка при выполнении процедуры';
        END IF;
    END;
    
    IF p_user_id IS NULL THEN
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указан пользователь';
	END IF;
    
    SELECT name, birth_date
    INTO v_user_name, v_user_birth_date
    FROM employees
    WHERE id = p_user_id
    LIMIT 1;
    
	IF v_user_name IS NULL OR v_user_name = '' THEN
		SET v_expected_error = TRUE;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Пользователь не найден';
    END IF;
    
	IF p_items_id IS NULL THEN
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указана номенклатура';
	END IF;

	SELECT COUNT(*) INTO v_items_count FROM items
    WHERE 1=1
    AND id = p_items_id
    AND deleted_at IS NOT NULL;
    
    IF v_items_count = 0 THEN 
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Такой номенклатуры не существует или она не была архивирована';
	END IF;

    START TRANSACTION;
    
	UPDATE items
		SET deleted_at = NULL
		WHERE id = p_items_id;
        
	INSERT INTO action_logs(atype,log) VALUES(4, CONCAT('Пользователь ', v_user_name,'(',v_user_birth_date, ')', ' разархивировал номенклатуру с id - ',p_items_id ));
	
    COMMIT;

    SELECT 100 AS status;
END $$

-- Обновлениие номенклатуры

CREATE DEFINER=`root`@`%` PROCEDURE `update_item`(
    IN p_item_id INT,
    IN p_name VARCHAR(255),
    IN p_unit_id INT,
    IN p_type_id INT,
    IN p_spec_ids JSON,
    IN p_inv_number VARCHAR(100),
    IN p_serial_number VARCHAR(100),
    IN p_comment VARCHAR(255),
    IN p_user_id INT
)
BEGIN
	DECLARE v_user_name VARCHAR(100);
    DECLARE v_user_birth_date VARCHAR(100);
    DECLARE v_item_count INT;
    DECLARE error_message TEXT;
    DECLARE v_expected_error BOOLEAN DEFAULT FALSE;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1 
			error_message = MESSAGE_TEXT;
        
        ROLLBACK;
        
		IF v_expected_error = TRUE THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = error_message;
		ELSE
			INSERT INTO error_logs(log) VALUES(error_message);
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Произошла ошибка при выполнении процедуры';
        END IF;
    END;
        
	IF p_user_id IS NULL THEN
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указан пользователь';
	END IF;
    
    SELECT name, birth_date
    INTO v_user_name, v_user_birth_date
    FROM employees
    WHERE id = p_user_id
    LIMIT 1;
    
	IF v_user_name IS NULL OR v_user_name = '' THEN
		SET v_expected_error = TRUE;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Пользователь не найден';
    END IF;
    
    SELECT COUNT(*) INTO v_item_count FROM items
    WHERE id = p_item_id;
    
    IF v_item_count = 0 THEN 
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Такой номенклатуры не существует';
	END IF;
    
    START TRANSACTION;
    
    UPDATE items 
    SET
		name = COALESCE(p_name, name),
        unit_id = COALESCE(p_unit_id, unit_id),
        type_id = COALESCE(p_type_id, type_id),
        inv_number = COALESCE(p_inv_number, inv_number),
        serial_number = COALESCE(p_serial_number, serial_number),
        comment = COALESCE(p_comment, comment),
        updated_at = NOW()
	WHERE items.id = p_item_id;
    
    IF p_spec_ids IS NOT NULL THEN

		DELETE FROM items_specs
		WHERE item_id = p_item_id;

		INSERT INTO items_specs(item_id, spec_id)
		SELECT p_item_id, jt.spec_id 
		FROM JSON_TABLE( p_spec_ids,'$[*]' COLUMNS(spec_id INT PATH '$')) jt;

	END IF;
            
	INSERT INTO action_logs(atype,log) VALUES(2, CONCAT('Пользователь ', v_user_name,'(',v_user_birth_date, ')', ' отредактировал номенклатуру с id - ','(',p_item_id,')' ));
	
    COMMIT;

    SELECT 100 AS status;
END $$

DELIMITER ;