use medical_center_warehouse;

DELIMITER $$

-- Создать расходную накладную

CREATE DEFINER=`root`@`%` PROCEDURE `create_expense_invoice`(
	IN p_doc_number VARCHAR(20),
	IN p_storage_id INT,
	IN p_accounting_object_id INT,
	IN p_comment TEXT,
	IN p_user_id INT
)
BEGIN
	DECLARE v_user_name VARCHAR(100);
    DECLARE v_user_birth_date VARCHAR(100);
    DECLARE error_message TEXT;
	DECLARE v_expected_error BOOLEAN DEFAULT FALSE;
	DECLARE v_created_invoice_id INT;
    
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
    
	IF p_doc_number IS NULL OR p_doc_number = ''  THEN
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указан номер документа';
	END IF;

	IF p_storage_id IS NULL THEN
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указан склад';
	END IF;
    
	IF p_accounting_object_id IS NULL THEN
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указан объект учета';
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
    
    INSERT INTO expense_invoices(
        doc_number,
        storage_id,
        accounting_object_id,
        comment
    )
    VALUES (
        p_doc_number,
        p_storage_id,
        p_accounting_object_id,
        p_comment
    );
    
	SET v_created_invoice_id = LAST_INSERT_ID();
	
	INSERT INTO action_logs(atype,log) VALUES(31, CONCAT('Пользователь ', v_user_name,'(',v_user_birth_date, ')', ' создал расходную накладную с id -  ', '(',v_created_invoice_id,')' ));
	
    COMMIT;

	SELECT 100 AS status;
END $$

-- Архивировать расходную накладуню

CREATE DEFINER=`root`@`%` PROCEDURE `delete_expense_invoice`(IN p_expense_invoice_id INT, IN p_user_id INT)
BEGIN
	DECLARE v_user_name VARCHAR(100);
    DECLARE v_user_birth_date VARCHAR(100);
    DECLARE v_expense_invoice_count INT;
    DECLARE v_expenses_ids TEXT;
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
    
    IF p_expense_invoice_id IS NULL THEN
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указана расходная накладная';
	END IF;
    
    SELECT COUNT(*) INTO v_expense_invoice_count FROM expense_invoices
    WHERE 1=1
    AND id = p_expense_invoice_id
    AND deleted_at IS NULL;
    
    IF v_expense_invoice_count = 0 THEN 
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Такой накладной не существует или она уже архивирована';
	END IF;
    
    START TRANSACTION;
    
    SELECT GROUP_CONCAT(id)
	INTO v_expenses_ids
	FROM expenses
	WHERE 1=1
    AND expense_invoice_id = p_expense_invoice_id
	AND deleted_at IS NULL;
    
    SET v_now = now();
    
    UPDATE expense_invoices
		SET deleted_at = v_now
		WHERE id = p_expense_invoice_id;
        
	UPDATE expenses
		SET deleted_at = v_now
        WHERE 1=1
		AND expense_invoice_id = p_expense_invoice_id
        AND deleted_at IS NULL;
        
	INSERT INTO action_logs(atype,log) VALUES(33, CONCAT('Пользователь ', v_user_name,'(',v_user_birth_date, ')', ' архивировал расходную наккладную с id - ',p_expense_invoice_id,'. Архивированы расходы с id: ', IFNULL(v_expenses_ids, 'нет приходов') ));

	SELECT 100 AS status;
END $$

-- Восстановить расходную накладную

CREATE DEFINER=`root`@`%` PROCEDURE `restore_expense_invoice`(IN p_expense_invoice_id INT, IN p_user_id INT)
BEGIN
DECLARE v_user_name VARCHAR(100);
    DECLARE v_user_birth_date VARCHAR(100);
    DECLARE v_expense_invoice_count INT;
    DECLARE v_expense_ids TEXT;
    DECLARE v_deleted_at_filter DATETIME;
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
    
    IF p_expense_invoice_id IS NULL THEN
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указана расходная накладная';
	END IF;
    
    SELECT COUNT(*) INTO v_expense_invoice_count FROM expense_invoices
    WHERE 1=1
    AND id = p_expense_invoice_id
    AND deleted_at IS NOT NULL;
    
    IF v_expense_invoice_count = 0 THEN 
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Такой накладной не существует или она уже разархивирована';
	END IF;

    START TRANSACTION;
    
	SELECT deleted_at INTO v_deleted_at_filter 
    FROM expense_invoices 
    WHERE 1=1
    AND expense_invoices.id = p_expense_invoice_id;
    
    SELECT GROUP_CONCAT(id)
	INTO v_expense_ids
	FROM expenses
	WHERE 1=1
    AND expense_invoice_id = p_expense_invoice_id
	AND deleted_at IS NOT NULL;
    
    UPDATE expense_invoices
		SET deleted_at = NULL
		WHERE id = p_expense_invoice_id;
        
	UPDATE expenses
		SET deleted_at = NULL
        WHERE 1=1
        AND expense_invoice_id = p_expense_invoice_id
		AND deleted_at = v_deleted_at_filter;
        
	INSERT INTO action_logs(atype,log) VALUES(34, CONCAT('Пользователь ', v_user_name,'(',v_user_birth_date, ')', ' разархивировал расходную наккладную с id - ',p_expense_invoice_id,'. Разрхивированы расходы с id: ', IFNULL(v_expense_ids, 'нет расходов') ));

	SELECT 100 AS status;
END $$

-- Изменить расходную накладную

CREATE DEFINER=`root`@`%` PROCEDURE `update_expense_invoise`(
	IN p_expense_invoice_id INT,
	IN p_doc_number VARCHAR(20),
	IN p_storage_id INT,
	IN p_accounting_object_id INT,
	IN p_comment TEXT,
	IN p_user_id INT,
	OUT created_invoice_id INT
)
BEGIN
	DECLARE v_user_name VARCHAR(100);
    DECLARE v_user_birth_date VARCHAR(100);
	DECLARE v_expense_invoice_count INT;
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
    
    SELECT COUNT(*) INTO v_expense_invoice_count FROM expense_invoices
    WHERE 1=1
    AND id = p_expense_invoice_id;
    
    IF v_expense_invoice_count = 0 THEN 
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Такой приходной накладной не существует';
	END IF;
    
    START TRANSACTION;
    
    UPDATE expense_invoices 
    SET
		doc_number = COALESCE(p_doc_number, doc_number),
        storage_id = COALESCE(p_storage_id, storage_id),
        accounting_object_id = COALESCE(p_accounting_object_id, accounting_object_id),
        comment = COALESCE(p_comment, comment),
        updated_at = NOW()
	WHERE expense_invoices.id = p_expense_invoice_id;
            
	INSERT INTO action_logs(atype,log) VALUES(32, CONCAT('Пользователь ', v_user_name,'(',v_user_birth_date, ')', ' отредактировал расходную накладную ',' id:(',p_expense_invoice_id,')' ));
	
    COMMIT;

	SELECT 100 AS status;
END $$

DELIMITER ;




