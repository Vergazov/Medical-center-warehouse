use medical_center_warehouse;

DELIMITER $$

-- Создать расход

CREATE DEFINER=`root`@`%` PROCEDURE `create_expense`(
    IN p_amount INT,
    IN p_price DECIMAL(10,2),
    IN p_manufactured_at DATETIME,
    IN p_expires_at DATETIME,
    IN p_item_id INT,
    IN p_expense_invoice_id INT,
    IN p_user_id INT
)
BEGIN

	DECLARE v_user_name VARCHAR(100);
    DECLARE v_user_birth_date VARCHAR(100);
    DECLARE v_created_expense_id INT;
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

	IF p_item_id IS NULL THEN
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указана номенклатура';
	END IF;
    
	IF p_expense_invoice_id IS NULL THEN
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
    
    INSERT INTO expenses(
        amount,
        price,
        manufactured_at,
        expires_at,
        item_id,
        expense_invoice_id
    )
    VALUES (
        p_amount,
        p_price,
        p_manufactured_at,
        p_expires_at,
        p_item_id,
        p_expense_invoice_id
    );
    
    SET v_created_expense_id = LAST_INSERT_ID();
    
	INSERT INTO action_logs(atype,log) VALUES(41, CONCAT('Пользователь ', v_user_name,'(',v_user_birth_date, ')', ' создал расход с id -  ','(',v_created_expense_id,')' ));
	
    COMMIT;
    
    SELECT 100 AS status;
END $$

-- Архивировать расход

CREATE DEFINER=`root`@`%` PROCEDURE `delete_expense`(IN p_expense_id INT, IN p_user_id INT)
BEGIN
	DECLARE v_user_name VARCHAR(100);
    DECLARE v_user_birth_date VARCHAR(100);
    DECLARE v_expense_count INT;
    DECLARE v_now DATETIME;
    DECLARE v_expense_invoice_id INT;
    DECLARE v_all_parchases_deleted INT;
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
    
	IF p_expense_id IS NULL THEN
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указан расход';
	END IF;

	SELECT COUNT(*) INTO v_expense_count FROM expenses
    WHERE 1=1
    AND id = p_expense_id
    AND deleted_at IS NULL;
    
    IF v_expense_count = 0 THEN 
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Такого расхода не существует или он уже архивирован';
	END IF;
    
    START TRANSACTION;
    
    SET v_now = now();
    
    UPDATE expenses
		SET deleted_at = now()
        WHERE 1=1
		AND id = p_expense_id
        AND deleted_at IS NULL;
	
    -- если мы удалили приход, проверяем не был лы он последним в накладной
    -- если это так, то удаляем и саму накладную
    IF ROW_COUNT() > 0 THEN
    
		SELECT expense_invoice_id 
		INTO v_expense_invoice_id
		FROM expenses
		WHERE id = p_expense_id;
    
		SELECT COUNT(*) INTO v_all_parchases_deleted 
        FROM expenses
        WHERE 1=1
        AND expense_invoice_id = v_expense_invoice_id
        AND deleted_at IS NULL;
        
        IF v_all_parchases_deleted = 0 THEN
            
            UPDATE expense_invoices
            SET deleted_at = v_now
            WHERE id = v_expense_invoice_id;
            
        END IF;
   END IF;
	
	INSERT INTO action_logs(atype,log) VALUES(43, CONCAT('Пользователь ', v_user_name,'(',v_user_birth_date, ')', ' архивировал расход с id - ', p_expense_id ));
	
    COMMIT;

    SELECT 100 AS status;
END $$ 

-- Восстановить расход

CREATE DEFINER=`root`@`%` PROCEDURE `restore_expense`(IN p_expense_id INT, IN p_user_id INT)
BEGIN
	DECLARE v_user_name VARCHAR(100);
    DECLARE v_user_birth_date VARCHAR(100);
    DECLARE v_expense_count INT;
    DECLARE v_expense_invoice_id INT;
    DECLARE v_count_expense_deleted INT;
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
    
	IF p_expense_id IS NULL THEN
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указан расход';
	END IF;

	SELECT COUNT(*) INTO v_expense_count FROM expenses
    WHERE 1=1
    AND id = p_expense_id
    AND deleted_at IS NOT NULL;
    
    IF v_expense_count = 0 THEN 
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Такого расхода не существует или он уже разархивирован';
	END IF;
    
    START TRANSACTION;
    
    UPDATE expenses
		SET deleted_at = NULL
        WHERE 1=1
        AND expenses.deleted_at IS NOT NULL
        AND expenses.id = p_expense_id;
        -- количество записей не в аррхиве в этой накладной. Должно быть 1 после апдейта,
	IF ROW_COUNT() > 0 THEN
    
		SELECT expense_invoice_id 
		INTO v_expense_invoice_id
		FROM expenses
		WHERE id = p_expense_id;
    
		SELECT COUNT(*) INTO v_count_expense_deleted
        FROM expenses
        WHERE 1=1
        AND expense_invoice_id = v_expense_invoice_id
        AND deleted_at IS NULL;
        
        IF v_count_expense_deleted = 1 THEN
            
            UPDATE expense_invoices
            SET deleted_at = NULL
            WHERE id = v_expense_invoice_id;
            
        END IF;
   END IF;
	
	INSERT INTO action_logs(atype,log) VALUES(44, CONCAT('Пользователь ', v_user_name,'(',v_user_birth_date, ')', ' разархивировал расход с id - ', p_expense_id ));
	
    COMMIT;

    SELECT 100 AS status;
END $$

CREATE DEFINER=`root`@`%` PROCEDURE `update_expense`(
    IN p_expense_id INT,
    IN p_amount INT,
    IN p_price DECIMAL(10,2),
    IN p_manufactured_at DATETIME,
    IN p_expires_at DATETIME,
    IN p_item_id INT,
    IN p_expense_invoice_id INT,
    IN p_user_id INT
)
BEGIN
	DECLARE v_user_name VARCHAR(100);
    DECLARE v_user_birth_date VARCHAR(100);
    DECLARE v_expense_count INT;
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
    
    SELECT COUNT(*) INTO v_expense_count 
    FROM expenses
    WHERE id = p_expense_id AND deleted_at IS NULL;

    IF v_expense_count = 0 THEN 
		SET v_expected_error = TRUE;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Такой записи расхода не существует';
    END IF;
    
    START TRANSACTION;
    
    UPDATE expenses 
    SET
        amount = COALESCE(p_amount, amount),
        price = COALESCE(p_price, price),
        manufactured_at = COALESCE(p_manufactured_at, manufactured_at),
        expires_at = COALESCE(p_expires_at, expires_at),
        item_id = COALESCE(p_item_id, item_id),
        expense_invoice_id = COALESCE(p_expense_invoice_id, expense_invoice_id),
        updated_at = NOW()
    WHERE id = p_expense_id;
    
	INSERT INTO action_logs(atype,log) VALUES(42, CONCAT('Пользователь ', v_user_name,'(',v_user_birth_date, ')', ' отредактировал расход c id - ','(',p_expense_id,')' ));

END $$

DELIMITER ;