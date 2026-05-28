use medical_center_warehouse;

DELIMITER $$

-- Создать приход

CREATE DEFINER=`root`@`%` PROCEDURE `create_purchase`(
    IN p_amount INT,
    IN p_price DECIMAL(10,2),
    IN p_vat INT,
    IN p_unit_id INT,
    IN p_manufactured_at DATETIME,
    IN p_expires_at DATETIME,
    IN p_item_id INT,
    IN p_purchase_invoice_id INT,
    IN p_comment TEXT,
    IN p_user_id INT
)
BEGIN

    DECLARE v_user_name VARCHAR(100);
    DECLARE v_user_birth_date VARCHAR(100);
	DECLARE error_message TEXT;
    DECLARE v_created_purchase_id INT;
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
        
    IF p_amount IS NULL THEN
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указано кол-во товара';
	END IF;
    
	IF p_price IS NULL THEN
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указана цена товара';
	END IF;
    
	IF p_unit_id IS NULL THEN
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указана единица измерения';
	END IF;
    
    IF p_manufactured_at IS NOT NULL AND p_expires_at IS NOT NULL THEN
		IF p_expires_at <= p_manufactured_at THEN
			SET v_expected_error = TRUE;
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Дата истечения срока годности должна быть больше даты производства';
        END IF;
    END IF;

	IF p_item_id IS NULL THEN
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указана номенклатура';
	END IF;
    
	IF p_purchase_invoice_id IS NULL THEN
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указан номер накладной';
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
    
    INSERT INTO purchases(
        amount,
        price,
        vat,
        unit_id,
        manufactured_at,
        expires_at,
        item_id,
        purchase_invoice_id,
        comment
    )
    VALUES (
        p_amount,
        p_price,
        p_vat,
        p_unit_id,
        p_manufactured_at,
        p_expires_at,
        p_item_id,
        p_purchase_invoice_id,
        p_comment
    );

    SET v_created_purchase_id = LAST_INSERT_ID();
    
	INSERT INTO action_logs(atype,log) VALUES(21, CONCAT('Пользователь ', v_user_name,'(',v_user_birth_date, ')', ' создал приход с id -  ','(',v_created_purchase_id,')' ));
	
    COMMIT;
    
    SELECT 100 AS status;
END $$

-- Архивировать приход

CREATE DEFINER=`root`@`%` PROCEDURE `delete_purchase`(IN p_purchase_id INT, IN p_user_id INT)
BEGIN
	DECLARE v_user_name VARCHAR(100);
    DECLARE v_user_birth_date VARCHAR(100);
    DECLARE v_purchase_count INT;
    DECLARE v_all_parchases_deleted INT;
    DECLARE v_purchase_invoice_id INT;
    DECLARE v_now DATETIME;
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
    
	IF p_purchase_id IS NULL THEN
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указан id прихода';
	END IF;

	SELECT COUNT(*) INTO v_purchase_count FROM purchases
    WHERE 1=1
    AND id = p_purchase_id
    AND deleted_at IS NULL;
    
    IF v_purchase_count = 0 THEN 
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Такого прихода не существует или он уже архивирован';
	END IF;
    
    START TRANSACTION;
    
    SET v_now = now();
    
    UPDATE purchases
		SET deleted_at = v_now
        WHERE 1=1
		AND id = p_purchase_id
        AND deleted_at IS NULL;
        
	-- если мы удалили приход, проверяем не был лы он последним в накладной
    -- если это так, то удаляем и саму накладную
    IF ROW_COUNT() > 0 THEN
    
		SELECT purchase_invoice_id 
		INTO v_purchase_invoice_id
		FROM purchases
		WHERE id = p_purchase_id;
    
		SELECT COUNT(*) INTO v_all_parchases_deleted 
        FROM purchases
        WHERE 1=1
        AND purchase_invoice_id = v_purchase_invoice_id
        AND deleted_at IS NULL;
        
        IF v_all_parchases_deleted = 0 THEN
            
            UPDATE purchase_invoices
            SET deleted_at = v_now
            WHERE id = v_purchase_invoice_id;
            
        END IF;
   END IF;
        
	INSERT INTO action_logs(atype,log) VALUES(23, CONCAT('Пользователь ', v_user_name,'(',v_user_birth_date, ')', ' архивировал приход с id - ', p_purchase_id ));
	
    COMMIT;

    SELECT 100 AS status;   
END $$

--  Восстановить приход

CREATE DEFINER=`root`@`%` PROCEDURE `restore_purchase`(IN p_purchase_id INT, IN p_user_id INT)
BEGIN
	DECLARE v_user_name VARCHAR(100);
    DECLARE v_user_birth_date VARCHAR(100);
    DECLARE v_purchase_count INT;
    DECLARE v_purchase_invoice_id INT;
    DECLARE v_count_parchases_deleted INT;
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
    
	IF p_purchase_id IS NULL THEN
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указана приходная накладная';
	END IF;

	SELECT COUNT(*) INTO v_purchase_count FROM purchases
    WHERE 1=1
    AND id = p_purchase_id
    AND deleted_at IS NOT NULL;
    
    IF v_purchase_count = 0 THEN 
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Такого прихода не существует или он уже разархивирован';
	END IF;
    
    START TRANSACTION;
    
    UPDATE purchases
		SET deleted_at = null
        WHERE 1=1
		AND id = p_purchase_id
        AND deleted_at IS NOT NULL;
     
     IF ROW_COUNT() > 0 THEN
    
		SELECT purchase_invoice_id 
		INTO v_purchase_invoice_id
		FROM purchases
		WHERE id = p_purchase_id;
    
		SELECT COUNT(*) INTO v_count_parchases_deleted 
        FROM purchases
        WHERE 1=1
		AND deleted_at IS NULL
        AND purchase_invoice_id = v_purchase_invoice_id;
        
        IF v_count_parchases_deleted = 1 THEN
            
            UPDATE purchase_invoices
            SET deleted_at = NULL
            WHERE id = v_purchase_invoice_id;
            
        END IF;
	END IF;
	
	INSERT INTO action_logs(atype,log) VALUES(24, CONCAT('Пользователь ', v_user_name,'(',v_user_birth_date, ')', ' разархивировал приход с id - ', p_purchase_id ));
	
    COMMIT;

    SELECT 100 AS status;
END $$

-- Восстановить приход

CREATE DEFINER=`root`@`%` PROCEDURE `update_purchase`(
    IN p_purchase_id INT,
    IN p_amount SMALLINT,
    IN p_price DECIMAL(10,2),
    IN p_vat INT,
    IN p_unit_id INT,
    IN p_manufactured_at DATETIME,
    IN p_expires_at DATETIME,
    IN p_item_id INT,
    IN p_purchase_invoice_id INT,
    IN p_comment TEXT,
    IN p_user_id INT
)
BEGIN
	DECLARE v_user_name VARCHAR(100);
    DECLARE v_user_birth_date VARCHAR(100);
    DECLARE v_purchase_count INT;
    DECLARE v_item_name VARCHAR(255);
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
    
    SELECT COUNT(*) INTO v_purchase_count 
    FROM purchases
    WHERE id = p_purchase_id AND deleted_at IS NULL;
    
    IF v_purchase_count = 0 THEN 
		SET v_expected_error = TRUE;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Такой записи прихода не существует';
    END IF;
    
    START TRANSACTION;
    
    UPDATE purchases 
    SET
        amount = COALESCE(p_amount, amount),
        price = COALESCE(p_price, price),
        vat = COALESCE(p_vat, vat),
        unit_id = COALESCE(p_unit_id, unit_id),
        manufactured_at = COALESCE(p_manufactured_at, manufactured_at),
        expires_at = COALESCE(p_expires_at, expires_at),
        item_id = COALESCE(p_item_id, item_id),
        purchase_invoice_id = COALESCE(p_purchase_invoice_id, purchase_invoice_id),
        comment = COALESCE(p_comment, comment),
        updated_at = NOW()
    WHERE id = p_purchase_id;
    
	INSERT INTO action_logs(atype,log) VALUES(22, CONCAT('Пользователь ', v_user_name,'(',v_user_birth_date, ')', ' отредактировал приход c id - ','(',p_purchase_id,')' ));

    SELECT 100 AS status;

END $$

DELIMITER ;
